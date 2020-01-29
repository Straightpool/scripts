#!/bin/bash 
# Basic Pooltool wrapper when running 2 nodes
# Created by Straight Pool, Ticker STR8
# Script version: 1.0
# Set RESTAPI_PORT=$1 in sendmytip.sh to accept the port parameter from this wrapper

RESTAPI_PORT=<REST_PORT_NODE1>

while true 
do

  if [[ $(jcli rest v0 leaders get -h http://127.0.0.1:${RESTAPI_PORT}/api | grep '1') ]]; then
     sendmytip.sh <REST_PORT_NODE1>
  else
     sendmytip.sh <REST_PORT_NODE2>
  fi
  sleep 60

done
