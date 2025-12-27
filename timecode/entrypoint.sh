#!/bin/bash
set -euo pipefail

# Defaults
: "${LOG_STDOUT:=true}"
: "${LOG_FILE:=/var/tmp/opencanary.log}"

function log_ts {
  date -u +"%Y-%m-%dT%H:%M:%S%z"
}

function initialise_repeating_events {
  echo "$(log_ts) [-] Initialising cron"
  rm -f crontab.txt
  touch crontab.txt

  echo "$(log_ts) [-] Adding heartbeat to cron"
  echo "* * * * * /scripts/heartbeat.sh" >> crontab.txt

  echo "$(log_ts) [-] Adding alarmcheck to cron"
  echo "*/15 * * * * /scripts/alarmcheck.sh" >> crontab.txt

  crontab crontab.txt
}

# show container BUILD env if provided
if [ -n "${BUILD-}" ]; then
  echo "$(log_ts) [-] BUILD=${BUILD}"
fi

# Ensure directory for log exists
mkdir -p "$(dirname "${LOG_FILE}")"

# clear logs
rm -f "${LOG_FILE}"
touch "${LOG_FILE}"
chmod 644 "${LOG_FILE}" || true

# start opencanaryd
if ! opencanaryd --start --uid=nobody --gid=nogroup; then
  echo "Unable to continue."
  echo "Exiting."
  exit 1
fi

# check cron setup
if ! crontab -l 2>/dev/null | grep -q 'heartbeat'; then
  if ! initialise_repeating_events; then
    echo "Unable to initialise repeating events."
    echo "Exiting."
    exit 1
  fi
fi

# start cron (sysv-style busybox/crond)
crond -L /dev/null

# Signal handling: try to stop opencanaryd on termination signals
_term() {
  echo "$(log_ts) [-] Caught termination signal, stopping services..."
  opencanaryd --stop || true
  exit 0
}
trap _term SIGTERM SIGINT

# If LOG_STDOUT is true (case-insensitive), tail the log to stdout so Docker captures it.
# Otherwise keep the script running in foreground to keep the container alive.
case "${LOG_STDOUT,,}" in
  "1"|"true"|"yes" )
    echo "$(log_ts) [-] Tailing ${LOG_FILE} to stdout"
    # -n +1 prints entire file; -F follows name (handles log rotation)
    tail -n +1 -F "${LOG_FILE}"
    ;;
  * )
    echo "$(log_ts) [-] LOG_STDOUT is false; not tailing. Sleeping to keep container alive."
    # Sleep indefinitely until signalled
    while true; do sleep 86400 & wait ${!}; done
    ;;
esac
