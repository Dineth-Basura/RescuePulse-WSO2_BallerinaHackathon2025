import ballerina/http;
import ballerina/io;

service /admin on httpListener {
    resource function get health() returns json { return { status: "admin-service:ok" }; }

    resource function get logs/[string file]() returns http:Response|json|error {
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

    resource function get users() returns json|error {
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


