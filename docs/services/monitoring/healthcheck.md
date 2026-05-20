# Healthcheck

The Healthcheck module provides a convenient endpoint for monitoring whether OpenCanary is up and running.

It returns a simple `200 OK` response status when hit. Unlike most other OpenCanary modules, it does not make any additions to the logs.

For example, if running in docker, the following may be used to ascertain the container's health status.

```yaml
    healthcheck:
      test: wget -q --spider http://127.0.0.1:1200/ || exit 1
      # ...
```

The endpoint can, of course, be used from any other suitable service (local or remote) responsible for (silently) monitoring the instance's state.

## Config

Inside ~/.opencanary.conf:

```json
{
    "healthcheck.enabled": true,
    "healthcheck.port": 1200,
    "healthcheck.banner": "",
    // ...
}
```

Override default settings:

- `port` (default: `1200`)
- `banner` (default: `Apache/2.4.66 (Ubuntu)`)
