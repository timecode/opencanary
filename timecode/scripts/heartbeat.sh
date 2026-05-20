#!/bin/bash
set -euo pipefail

: "${LOG_FILE:=/var/tmp/opencanary.log}"
: "${HEARTBEAT_PORT:=1210}"

log_ts() { date -u +"%Y-%m-%dT%H:%M:%S%z"; }

# Ensure log directory exists
mkdir -p "$(dirname "${LOG_FILE}")"

# wait for heartbeat endpoint (10s timeout)
if ! timeout 10 sh -c "until wget --spider 127.0.0.1:${HEARTBEAT_PORT}/heartbeat >/dev/null 2>&1; do sleep 1; done"; then
  echo "$(log_ts) [-] Invalid response trying to trigger heartbeat on port ${HEARTBEAT_PORT}!" >> "${LOG_FILE}"
fi
