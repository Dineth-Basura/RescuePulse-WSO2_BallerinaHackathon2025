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
}

