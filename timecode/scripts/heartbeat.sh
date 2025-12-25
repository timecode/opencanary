#!/bin/bash

logfile=/var/tmp/opencanary.log

timeout 10 sh -c "until wget --spider 127.0.0.1:1210/heartbeat; do sleep 1; done 2>/dev/null"

if [ $? -ne 0 ]; then
  ts=$(date -u +"%Y-%m-%dT%H:%M:%S%z")
  echo "${ts} [-] Invalid response trying to trigger heartbeat!" >> ${logfile}
fi
