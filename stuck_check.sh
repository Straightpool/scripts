#!/bin/bash
# Basic StakePool Node Restart script after stuck_notifier is received
# Created by Straight Pool, Ticker STR8

while true
do
  LastLog=`journalctl -u <SHELLEYSERVICENAME>.service | tail -n 1`

  if [[ $(echo $LastLog | grep 'stuck_notifier') ]]; then
    Uptime=`/home/<USER>/.cargo/bin/jcli rest v0 node stats get -h http://127.0.0.1:<REST_PORT>/api | grep 'uptime'`
    echo "Restarting due to stuck_notifier at $Uptime" >> /home/<USER>/logs/stuck_check.log
    systemctl stop <SHELLEYSERVICENAME>
    sleep 5
    systemctl start <SHELLEYSERVICENAME>
  fi

sleep 10
done
