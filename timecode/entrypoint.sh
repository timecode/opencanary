#!/bin/bash

function create_crontab_txt {
  ts=$(date -u +"%Y-%m-%dT%H:%M:%S%z")
  echo "${ts} [-] Initialising cron"
  echo "${ts} [-] Adding heartbeat to cron"
  echo "* * * * * /scripts/heartbeat.sh" > crontab.txt
  echo "${ts} [-] Adding alarmcheck to cron"
  echo "*/15 * * * * /scripts/alarmcheck.sh" >> crontab.txt
  # see https://crontab.cronhub.io/

  # initial launch
  /scripts/heartbeat.sh
  /scripts/alarmcheck.sh
}

function start_cron {
  crontab crontab.txt
  crond -L /dev/null
}

rm -f /var/tmp/opencanary.log
touch /var/tmp/opencanary.log

# --allow-run-as-root | --uid=nobody --gid=nogroup
opencanaryd --start --uid=nobody --gid=nogroup

if ! crontab -l | grep -q 'heartbeat'; then
  create_crontab_txt
  start_cron
fi

tail -n +1 -f /var/tmp/opencanary.log
