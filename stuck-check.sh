#!/bin/bash
# Basic StakePool Node Restart script after stuck_notifier or any other bad keyword is received in logs
# Created by Straight Pool, Ticker STR8
# Script version: 2.4

# This script assumes you have setup your pool as a systemd service
#
# In node-config you can define the time threshold when you want the node to throw the stuck_notifier with e.g.: 
# no_blockchain_updates_warning_interval: 4m
# Default is 30m

REST_API="http://127.0.0.1:<REST_PORT>/api"

journalctl -u <jormungandr>.service -n 1 -f | grep --line-buffered 'stuck_notifier\|task panicked\|cannot schedule getting next block' | while read LINE
do
  if [[ -n $LINE ]]; then
    NOW=$(date +"%Y-%m-%d_%H:%M:%S_%Z")  
    Uptime=`jcli rest v0 node stats get -h $REST_API | grep 'uptime'`
    LastBlockHeight=`jcli rest v0 node stats get -h $REST_API | grep 'lastBlockHeight'`
    if test -z "$Uptime"
    then
      echo "Node currently offline / bootstrapping, ignoring redundant restart logline"
    else 
      echo "Shutting down node due to stuck keyword with $Uptime at $LastBlockHeight at $NOW" 
      jcli rest v0 shutdown get --host $REST_API
      sleep 5
    fi
  fi
done
