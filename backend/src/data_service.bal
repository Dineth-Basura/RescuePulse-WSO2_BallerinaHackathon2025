import ballerina/http;
import ballerina/log;

type WeatherRecord record {
    float rainMm;
    float windKph;
    float tempC;
    float humidityPct;
    float soilSatPct;
    string location;
    string timestamp;
};

WeatherRecord[] weatherData = [];

service /data on httpListener {
    resource function get health() returns json { return { status: "data-service:ok" }; }

    resource function post ingest(@http:Payload WeatherRecord rec) returns json {
        lock {
            weatherData.push(rec);
        }
        log:printInfo("Ingested record for " + rec.location + " at " + rec.timestamp);
        return { status: "stored" };
    }

    resource function get latest/[string location]() returns WeatherRecord[]|json {
        WeatherRecord[] out = [];
        foreach var r in weatherData {
            if r.location == location {
                out.push(r);
            }
        }
        if out.length() == 0 { return { message: "no data" }; }
        return out;
    }

    resource function post ingestBatch(@http:Payload WeatherRecord[] recs) returns json {
        int n = 0;
        lock {
            foreach var r in recs { weatherData.push(r); n += 1; }
        }
        log:printInfo("Batch ingested records count=" + n.toString());
        return { status: "stored", count: n };
    }

    resource function get locations() returns json {
        map<boolean> seen = {};
        string[] out = [];
        foreach var r in weatherData {
            if !seen.hasKey(r.location) { seen[r.location] = true; out.push(r.location); }
        }
        return { locations: out };
    }

    resource function get all() returns WeatherRecord[]|json {
        if weatherData.length() == 0 { return { message: "no data" }; }
        return weatherData;
    }

    resource function get stats() returns json {
        int n = weatherData.length();
        if n == 0 { return { count: 0 };
        }
        float sumRain = 0.0; float sumWind = 0.0; float sumTemp = 0.0; float sumHum = 0.0; float sumSoil = 0.0;
        foreach var r in weatherData {
            sumRain += r.rainMm; sumWind += r.windKph; sumTemp += r.tempC; sumHum += r.humidityPct; sumSoil += r.soilSatPct;
        }
        return {
            count: n,
            avgRainMm: sumRain / n,
            avgWindKph: sumWind / n,
            avgTempC: sumTemp / n,
            avgHumidityPct: sumHum / n,
            avgSoilSatPct: sumSoil / n
        };
    }
}

