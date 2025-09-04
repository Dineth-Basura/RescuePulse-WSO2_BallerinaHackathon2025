import ballerina/test;
import ballerina/http;

@test:Config {}
function testSignupLogin() returns error? {
    http:Client c = check new ("http://localhost:8080");
    json s = check c->post("/auth/signup", { username: "alice", password: "pass1234" }, targetType = json);
    test:assertEquals(s.status, "ok");
    json l = check c->post("/auth/login", { username: "alice", password: "pass1234" }, targetType = json);
    test:assertEquals(l.status, "ok");
    test:assertTrue(l.token is string);
}

