#!/bin/bash
# Basic StakePool Node Restart script after stuck_notifier is received
# Created by Straigt Pool, Ticket STR8

while true
do
  LastLog=`journalctl -u shelleypoold.service | tail -n 1`

  if [[ $(echo $LastLog | grep 'stuck_notifier') ]]; then
    Uptime=`/home/sl/.cargo/bin/jcli rest v0 node stats get -h http://127.0.0.1:9099/api | grep 'uptime'`
    echo "Restarting due to stuck_notifier at $Uptime" >> /home/sl/logs/stuck_check.log
    systemctl stop shelleypoold
    sleep 5
    systemctl start shelleypoold
  fi

sleep 10
done
