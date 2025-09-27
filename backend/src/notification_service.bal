import ballerina/http;
import ballerina/log;
// no time import; using simple counters

type Notification record {
    string id;
    string channel; // in-app, email (simulated), sms (simulated)
    string target;
    string title;
    string body;
    string createdAt;
};

final Notification[] notifications = [];
int notifSeq = 0;

service /notify on httpListener {
    resource function get health() returns json { return { status: "notification-service:ok" }; }

    resource function post publish(@http:Payload Notification n) returns json|Notification {
        string id = n.id.length() > 0 ? n.id : notifNewId();
        Notification nn = {
            id,
            channel: n.channel,
            target: n.target,
            title: n.title,
            body: n.body,
            createdAt: notifNow()
        };
        lock { notifications.push(nn); }
        log:printInfo("Notification to=" + nn.target + " via=" + nn.channel + " title=" + nn.title);
        return nn;
    }

    resource function get list() returns Notification[] { return notifications; }

    resource function get for/[string target]() returns Notification[]|json {
        Notification[] out = [];
        foreach var n in notifications { if n.target == target { out.push(n); } }
        if out.length() == 0 { return { message: "no notifications" }; }
        return out;
    }
}

function notifNow() returns string { notifSeq = notifSeq + 1; return "t-" + notifSeq.toString(); }
function notifNewId() returns string { notifSeq = notifSeq + 1; return "n-" + notifSeq.toString(); }


