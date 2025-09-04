import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/file;

type PredictRequest record {
    float rainMm;
    float windKph;
    float tempC;
    float humidityPct;
    float soilSatPct;
};

type PredictResponse record {
    float riskScore;
};

type TrainRecord record {
    float rainMm;
    float windKph;
    float tempC;
    float humidityPct;
    float soilSatPct;
};

public class RiskModel {
    public float wRain = 0.35;
    public float wWind = 0.25;
    public float wTemp = 0.15;
    public float wHumidity = 0.10;
    public float wSoil = 0.15;
    public float bias = 0.0;

    function predict(float rainMm, float windKph, float tempC, float humidityPct, float soilSatPct) returns float {
        float score = (rainMm / 200.0) * self.wRain
            + (windKph / 120.0) * self.wWind
            + ((40.0 - tempC) / 40.0) * self.wTemp
            + (humidityPct / 100.0) * self.wHumidity
            + (soilSatPct / 100.0) * self.wSoil + self.bias;
        if score < 0.0 { return 0.0; }
        if score > 1.0 { return 1.0; }
        return score;
    }
}

final RiskModel MODEL = new;

service /ai on httpListener {
    resource function get health() returns json {
        return { status: "ai-service:ok" };
    }

    resource function post predict(@http:Payload PredictRequest req) returns PredictResponse {
        float risk = MODEL.predict(req.rainMm, req.windKph, req.tempC, req.humidityPct, req.soilSatPct);
        log:printDebug("Predicted risk: " + risk.toString());
        return { riskScore: risk };
    }

    resource function post train(@http:Payload TrainRecord[] data) returns json|error {
        if data.length() == 0 { return { status: "error", message: "no data" }; }
        float[] w = [MODEL.wRain, MODEL.wWind, MODEL.wTemp, MODEL.wHumidity, MODEL.wSoil, MODEL.bias];
        float lr = 0.01;
        int epochs = 200;
        int used = 0;
        foreach int epoch in 0..<(epochs) {
            float[] grad = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
            int n = 0;
            foreach var rec in data {
                float x1 = rec.rainMm / 200.0;
                float x2 = rec.windKph / 120.0;
                float x3 = (40.0 - rec.tempC) / 40.0;
                float x4 = rec.humidityPct / 100.0;
                float x5 = rec.soilSatPct / 100.0;
                float y = x1; // proxy target
                float yhat = w[0]*x1 + w[1]*x2 + w[2]*x3 + w[3]*x4 + w[4]*x5 + w[5];
                float err = yhat - y;
                grad[0] += err * x1; grad[1] += err * x2; grad[2] += err * x3; grad[3] += err * x4; grad[4] += err * x5; grad[5] += err;
                n += 1;
            }
            if n == 0 { break; }
            foreach int j in 0...5 { w[j] = w[j] - lr * (grad[j] / n); }
            used = n;
        }
        MODEL.wRain = w[0]; MODEL.wWind = w[1]; MODEL.wTemp = w[2]; MODEL.wHumidity = w[3]; MODEL.wSoil = w[4]; MODEL.bias = w[5];
        var dirRes = file:createDir("models");
        if dirRes is error {
            // ignore if already exists or cannot create
        }
        string modelStr = w[0].toString() + "," + w[1].toString() + "," + w[2].toString() + "," + w[3].toString() + "," + w[4].toString() + "," + w[5].toString();
        check io:fileWriteString("models/model.txt", modelStr);
        return { status: "ok", rowsUsed: used };
    }
}

