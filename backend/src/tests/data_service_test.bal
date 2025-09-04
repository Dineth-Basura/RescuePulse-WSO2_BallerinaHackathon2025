import ballerina/test;
import ballerina/http;

type StoreResponse record { string status; };

@test:Config {}
function testIngestAndFetch() returns error? {
    http:Client c = check new ("http://localhost:8080");
    StoreResponse resp = check c->post("/data/ingest", { rainMm: 10.0, windKph: 5.0, tempC: 28.0, humidityPct: 55.0, soilSatPct: 40.0, location: "LOC1", timestamp: "2024-09-01T00:00:00Z" }, targetType = StoreResponse);
    test:assertEquals(resp.status, "stored");
    json list = check c->get("/data/latest/LOC1", targetType = json);
    test:assertTrue(list is json[]);
}

