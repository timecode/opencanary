#!/bin/bash

function initialise_repeating_events {
  ts=$(date -u +"%Y-%m-%dT%H:%M:%S%z")
  # see https://crontab.cronhub.io/
  echo "${ts} [-] Initialising cron"
  rm -f crontab.txt
  touch crontab.txt

  echo "${ts} [-] Adding heartbeat to cron"
  echo "* * * * * /scripts/heartbeat.sh" >> crontab.txt

  echo "${ts} [-] Adding alarmcheck to cron"
  echo "*/15 * * * * /scripts/alarmcheck.sh" >> crontab.txt

  crontab crontab.txt

  # just leave to cron, or trigger right now too?
  # /scripts/heartbeat.sh
  # /scripts/alarmcheck.sh
}

# clear logs
rm -f /var/tmp/opencanary.log
touch /var/tmp/opencanary.log

# start opencanaryd
if ! opencanaryd --start --uid=nobody --gid=nogroup; then
  echo "Unable to continue."
  echo "Exiting."
  exit 1
fi

# check cron setup
if ! crontab -l | grep -q 'heartbeat'; then
  if ! initialise_repeating_events; then
    echo "Unable to initialise repeating events."
    echo "Exiting."
    exit 1
  fi
fi

# start cron
crond -L /dev/null

tail -n +1 -f /var/tmp/opencanary.log
