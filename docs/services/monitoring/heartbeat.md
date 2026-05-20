# Heartbeat

The Heartbeat module provides a convenient endpoint for monitoring whether OpenCanary is up and running; especially useful if the built in alerts are not in use.

As well as returning a simple `200 OK` response status when hit, the Heartbeat module also makes additions to the logs. These logs have their own unique signature and are designed to be able to be filtered by a log monitoring pipeline - they can then be surfaced for anything from visual confidence or as part of a metric of 'expected' behaviour that triggers an alert under some 'divergent' condition (e.g. "ALERT: Canary comms are down!").

Log example (reduced fields shown for brevity):

```txt
dst_host=127.0.0.1 dst_port=1210 logdata={"_TYPE":"HEARTBEAT"} logtype=100 node_id=example
```

Triggering examples (repeated frequently) include from:

- an 'on device' service (`cron`, `systemd`, etc), with `wget`
- a remote device, which adds an end-to-end confirmation too

## Config

Inside ~/.opencanary.conf:

```json
{
    "heartbeat.enabled": true,
    "heartbeat.port": 1210,
    "heartbeat.banner": "",
    // ...
}
```

Override default settings:

- `port` (default: `1210`)
- `banner` (default: `Apache/2.4.66 (Ubuntu)`)
