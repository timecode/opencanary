# Alarmcheck

The Alarmcheck module provides a convenient endpoint for monitoring whether OpenCanary is up and running; especially useful if the built in alerts are not in use.

As well as returning a simple `200 OK` response status when hit, the Alarmcheck module also makes additions to the logs. These logs have their own unique signature and are designed to be able to be filtered by a log monitoring pipeline - they can then be surfaced for anything from visual confidence or as part of a metric of 'expected' behaviour that triggers an alert under some 'divergent' condition (e.g. "ALERT: Canary test alarm expected but didn't happen!").

Log example (reduced fields shown for brevity):

```txt
dst_host=127.0.0.1 dst_port=1211 logdata={"_TYPE":"ALARMCHECK"} logtype=101 node_id=example
```

Triggering examples (repeated much less frequently) include from:

- an 'on device' service (`cron`, `systemd`, etc), with `wget`
- a remote device, which adds an end-to-end confirmation too

The intended use-case is more akin to a real-world fire alarm test at a specified time, rather than simply to monitor the system being (a)live (which should be monitored much more frequently - see [Heartbeat module](./heartbeat.md))

## Config

Inside ~/.opencanary.conf:

```json
{
    "alarmcheck.enabled": true,
    "alarmcheck.port": 1211,
    "alarmcheck.banner": "",
    // ...
}
```

Override default settings:

- `port` (default: `1211`)
- `banner` (default: `Apache/2.4.66 (Ubuntu)`)
