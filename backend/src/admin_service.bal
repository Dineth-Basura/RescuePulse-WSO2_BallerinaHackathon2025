import ballerina/http;
import ballerina/io;

service /admin on httpListener {
    resource function get health() returns json { return { status: "admin-service:ok" }; }

    resource function get logs/[string file](http:Request req) returns http:Response|json|error {
        if !isAdmin(req) {
            return { message: "forbidden" };
        }
        string[] allow = ["login.txt", "users.txt", "incidents.txt"];
        boolean ok = false;
        foreach var n in allow { if n == file { ok = true; break; } }
        if !ok { return { message: "not allowed" }; }
        string path = "logs/" + file;
        var r = io:fileReadString(path);
        if r is string {
            http:Response res = new;
            res.setPayload(r);
            res.setHeader("content-type", "text/plain; charset=utf-8");
            return res;
        }
        return { message: "not found" };
    }

    resource function get users(http:Request req) returns json|error {
        if !isAdmin(req) {
            return { message: "forbidden" };
        }
        var r = io:fileReadString("logs/users.txt");
        if r is string {
            string data = r.trim();
            if data.length() == 0 { return { users: [] }; }
            string[] lines = splitByDelimiterAdm(data, "\n");
            string[] names = [];
            foreach var ln in lines {
                if ln.length() == 0 { continue; }
                string[] parts = splitByDelimiterAdm(ln, "\t");
                if parts.length() >= 1 { names.push(parts[0]); }
            }
            return { users: names };
        }
        return { users: [] };
    }
}

function splitByDelimiterAdm(string input, string delim) returns string[] {
    string[] parts = [];
    string remaining = input;
    while true {
        int|() idxOrNil = remaining.indexOf(delim);
        int idx = idxOrNil is int ? idxOrNil : -1;
        if idx < 0 {
            parts.push(remaining);
            break;
        }
        string head = remaining.substring(0, idx);
        parts.push(head);
        remaining = remaining.substring(idx + delim.length());
        if remaining.length() == 0 { break; }
    }
    return parts;
}

function isAdmin(http:Request req) returns boolean {
    var authzOrErr = req.getHeader("authorization");
    if !(authzOrErr is string) { return false; }
    string authz = <string>authzOrErr;
    if authz.length() == 0 { return false; }
    // Expect format: Bearer demo-token-<username>
    string prefix = "Bearer ";
    if !authz.startsWith(prefix) { return false; }
    string tok = authz.substring(prefix.length());
    if !tok.startsWith("demo-token-") { return false; }
    string user = tok.substring("demo-token-".length());
    // Minimal role lookup by reading users.txt if available
    var r = io:fileReadString("logs/users.txt");
    if r is string {
        string data = r.trim();
        if data.length() == 0 { return false; }
        string[] lines = splitByDelimiterAdm(data, "\n");
        foreach var ln in lines {
            if ln.length() == 0 { continue; }
            string[] parts = splitByDelimiterAdm(ln, "\t");
            if parts.length() >= 1 {
                string u = parts[0].trim();
                if u == user {
                    string role = parts.length() >= 3 ? parts[2].trim() : (u == "admin" ? "admin" : "user");
                    return role == "admin";
                }
            }
        }
    }
    // Fallback: allow built-in admin username
    return user == "admin";
}


