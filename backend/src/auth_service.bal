import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/file;

type SignupRequest record {
    string username;
    string password;
};

type LoginRequest record {
    string username;
    string password;
};

type AuthResponse record {
    string status;
    string message?;
    string token?;
};

type User record {
    string username;
    string password;
    string createdAt?;
};

final string LOG_DIR = "logs";
final string LOGIN_LOG_PATH = LOG_DIR + "/login.txt";
final string USERS_PATH = LOG_DIR + "/users.txt";

// In-memory user store
final map<User> users = {};

function init() returns error? {
    // Ensure log dir and load existing users from file
    check ensureLogsDir();
    check loadUsersFromFile();
}

service /auth on httpListener {
    resource function get health() returns json { return { status: "auth-service:ok" }; }

    resource function post signup(@http:Payload SignupRequest req) returns AuthResponse {
        string uname = req.username.trim();
        string pword = req.password.trim();
        if uname.length() == 0 || pword.length() == 0 {
            return { status: "error", message: "username and password required" };
        }
        if users.hasKey(req.username) {
            return { status: "error", message: "user exists" };
        }
        users[uname] = { username: uname, password: pword, createdAt: "" };
        if persistUser(uname, pword) is error {
            // ignore persist error
        }
        log:printInfo("[signup] user=" + uname);
        return { status: "ok" };
    }

    resource function post login(@http:Payload LoginRequest req) returns AuthResponse {
        boolean success = false;
        string message = "";
        string uname = req.username.trim();
        string pword = req.password.trim();
        var maybeUser = users[uname];
        if maybeUser is User {
            User u = maybeUser;
            if u.password == pword {
                success = true;
            } else {
                message = "invalid credentials";
            }
        } else {
            message = "user not found";
        }
        string line = uname + "\t" + (success ? "SUCCESS" : "FAIL");
        if ensureLogsDir() is error {}
        if appendLogLine(LOGIN_LOG_PATH, line) is error {}
        if success {
            log:printInfo("[login] SUCCESS user=" + uname);
            return { status: "ok", token: "demo-token-" + uname };
        }
        log:printInfo("[login] FAIL user=" + uname + " reason=" + message);
        return { status: "error", message };
    }

    resource function get debug/users() returns json {
        string[] list = [];
        foreach var [k, _] in users.entries() {
            list.push(k);
        }
        return { users: list };
    }
}

function ensureLogsDir() returns error? {
    var dirRes = file:createDir(LOG_DIR);
    if dirRes is error {
        // ignore if exists or cannot create
    }
}

function appendLogLine(string path, string line) returns error? {
    string content = "";
    var readRes = io:fileReadString(path);
    if readRes is string {
        content = readRes;
    }
    if content.length() > 0 {
        content = content + "\n" + line;
    } else {
        content = line;
    }
    check io:fileWriteString(path, content);
}

function persistUser(string username, string password) returns error? {
    // Append user to users.txt as TSV
    string line = username + "\t" + password;
    string content = "";
    var r = io:fileReadString(USERS_PATH);
    if r is string { content = r; }
    if content.length() > 0 { content = content + "\n" + line; } else { content = line; }
    check ensureLogsDir();
    check io:fileWriteString(USERS_PATH, content);
}

function loadUsersFromFile() returns error? {
    var r = io:fileReadString(USERS_PATH);
    if r is string {
        string data = r.trim();
        if data.length() == 0 { return; }
        string[] lines = splitByDelimiter(data, "\n");
        foreach var ln in lines {
            if ln.length() == 0 { continue; }
            string[] parts = splitByDelimiter(ln, "\t");
            if parts.length() >= 2 {
                string u = parts[0].trim();
                string p = parts[1].trim();
                if u.length() > 0 {
                    users[u] = { username: u, password: p, createdAt: "" };
                }
            }
        }
    }
}

function splitByDelimiter(string input, string delim) returns string[] {
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

