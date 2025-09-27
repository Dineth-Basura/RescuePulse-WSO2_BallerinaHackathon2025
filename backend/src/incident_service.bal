import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/file;
// no time import; using simple counters for ids/timestamps

type Incident record {
    string id;
    string location;
    string description;
    string severity; // LOW, MEDIUM, HIGH, CRITICAL
    string status; // OPEN, ACK, RESOLVED
    string createdAt;
    string updatedAt;
};

final string INCIDENTS_PATH = "logs/incidents.txt";
final map<Incident> incidents = {};
boolean incidentsLoaded = false;
int incSeq = 0;

service /incident on httpListener {
    resource function get health() returns json { return { status: "incident-service:ok" }; }

    resource function post create(@http:Payload Incident body) returns json|Incident {
        ensureIncidentsLoaded();
        string id = body.id.length() > 0 ? body.id : newId();
        Incident inc = {
            id,
            location: body.location,
            description: body.description,
            severity: body.severity,
            status: body.status.length() > 0 ? body.status : "OPEN",
            createdAt: body.createdAt.length() > 0 ? body.createdAt : nowStampInc(),
            updatedAt: nowStampInc()
        };
        incidents[id] = inc;
        if persistIncidentsToFile() is error {}
        log:printInfo("Incident created id=" + id + " at " + inc.location);
        return inc;
    }

    resource function put update/[string id](@http:Payload Incident body) returns json|Incident {
        ensureIncidentsLoaded();
        var m = incidents[id];
        if m is () { return { message: "not found" }; }
        Incident cur = <Incident>m;
        Incident upd = {
            id,
            location: body.location.length() > 0 ? body.location : cur.location,
            description: body.description.length() > 0 ? body.description : cur.description,
            severity: body.severity.length() > 0 ? body.severity : cur.severity,
            status: body.status.length() > 0 ? body.status : cur.status,
            createdAt: cur.createdAt,
            updatedAt: nowStampInc()
        };
        incidents[id] = upd;
        if persistIncidentsToFile() is error {}
        return upd;
    }

    resource function get [string id]() returns json|Incident {
        ensureIncidentsLoaded();
        var m = incidents[id];
        if m is () { return { message: "not found" }; }
        return <Incident>m;
    }

    resource function get list() returns Incident[] {
        ensureIncidentsLoaded();
        Incident[] out = [];
        foreach var [_, inc] in incidents.entries() { out.push(inc); }
        return out;
    }

    resource function delete [string id]() returns json {
        ensureIncidentsLoaded();
        if !incidents.hasKey(id) { return { status: "not_found" }; }
        _ = incidents.remove(id);
        if persistIncidentsToFile() is error {}
        return { status: "deleted" };
    }
}

function ensureLogsDirInc() returns error? {
    var dirRes = file:createDir("logs");
    if dirRes is error { }
}

function persistIncidentsToFile() returns error? {
    string content = "";
    foreach var [_, inc] in incidents.entries() {
        string line = inc.id + "\t" + inc.location + "\t" + inc.description + "\t" + inc.severity + "\t" + inc.status + "\t" + inc.createdAt + "\t" + inc.updatedAt;
        if content.length() == 0 { content = line; } else { content = content + "\n" + line; }
    }
    check ensureLogsDirInc();
    check io:fileWriteString(INCIDENTS_PATH, content);
}

function loadIncidentsFromFile() returns error? {
    var r = io:fileReadString(INCIDENTS_PATH);
    if r is string {
        string data = r.trim();
        if data.length() == 0 { return; }
        string[] lines = splitByDelimiterInc(data, "\n");
        foreach var ln in lines {
            if ln.length() == 0 { continue; }
            string[] parts = splitByDelimiterInc(ln, "\t");
            if parts.length() >= 7 {
                Incident inc = {
                    id: parts[0],
                    location: parts[1],
                    description: parts[2],
                    severity: parts[3],
                    status: parts[4],
                    createdAt: parts[5],
                    updatedAt: parts[6]
                };
                incidents[inc.id] = inc;
            }
        }
    }
}

function splitByDelimiterInc(string input, string delim) returns string[] {
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

function nowStampInc() returns string {
    incSeq = incSeq + 1;
    return "t-" + incSeq.toString();
}

function newId() returns string {
    incSeq = incSeq + 1;
    return "inc-" + incSeq.toString();
}

function ensureIncidentsLoaded() {
    if !incidentsLoaded {
        if ensureLogsDirInc() is error { }
        if loadIncidentsFromFile() is error { }
        incidentsLoaded = true;
    }
}


