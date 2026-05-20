#!/bin/bash
set -euo pipefail

: "${LOG_FILE:=/var/tmp/opencanary.log}"
: "${ALARMCHECK_PORT:=1211}"

log_ts() { date -u +"%Y-%m-%dT%H:%M:%S%z"; }

# Ensure log directory exists
mkdir -p "$(dirname "${LOG_FILE}")"

# wait for alarmcheck endpoint (10s timeout)
if ! timeout 10 sh -c "until wget --spider 127.0.0.1:${ALARMCHECK_PORT}/alarmcheck >/dev/null 2>&1; do sleep 1; done"; then
  echo "$(log_ts) [-] Invalid response trying to trigger alarmcheck on port ${ALARMCHECK_PORT}!" >> "${LOG_FILE}"
fi
