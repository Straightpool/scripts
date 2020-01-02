#!/bin/bash
#
# Author: Michael Fazio (sandstone.io)
# Modification by Straightpool (https://straightpool.github.io/about/) 
#
# This script monitors a Jormungandr node for "liveness" and executes a shutdown if the node is determined
# to be "stuck". A node is "stuck" if the time elapsed since last block exceeds the sync tolerance 
# threshold. The script does NOT perform a restart on the Jormungandr node. Instead we rely on process 
# managers such as systemd to perform restarts.
#
# Modifications: 
# - The script also considers a node stuck if it is too long offline or in bootstrap mode. It then uses systemd 
#   to actually restart the node, as a simple shutdown won't work in these scenarios
#   Run the script with sudo rights to make use of this added functionality
# - Added uptime to logging output
# - Modified timing of SYNC_TOLERANCE_SECONDS from 240 to 300 seconds
# - Added monitoring of stuck node recovery times and record recovery times to fine tune parameter SYNC_TOLERANCE_SECONDS
#
# Version 2.5

POLLING_INTERVAL_SECONDS=30
SYNC_TOLERANCE_SECONDS=300
BOOTSTRAP_TOLERANCE_SECONDS=480
REST_API="http://127.0.0.1:<REST_PORT>/api"
BOOTSTRAP_TIME=$SECONDS
DIFF_SECONDS_OLD_CYCLE=0
RECOVER_MAX_SECONDS=0

while true; do

    LAST_BLOCK=$(jcli rest v0 node stats get --output-format json --host $REST_API 2> /dev/null)
    LAST_BLOCK_HEIGHT=$(echo $LAST_BLOCK | jq -r .lastBlockHeight)
    LAST_BLOCK_DATE=$(echo $LAST_BLOCK | jq -r .lastBlockTime)
    UPTIME=$(echo $LAST_BLOCK | jq -r .uptime)
    LAST_BLOCK_TIME=$(date -d$LAST_BLOCK_DATE +%s 2> /dev/null)
    CURRENT_TIME=$(date +%s)
    if ((LAST_BLOCK_TIME > 0)); then
        DIFF_SECONDS=$((CURRENT_TIME - LAST_BLOCK_TIME))
        if ((DIFF_SECONDS > SYNC_TOLERANCE_SECONDS)); then
            echo "Jormungandr out-of-sync. Time difference of $DIFF_SECONDS seconds. Shutting down node with uptime $UPTIME..."
            jcli rest v0 shutdown get --host $REST_API
            BOOTSTRAP_TIME=$SECONDS
        else
            BOOTSTRAP_TIME=$SECONDS
            if ((DIFF_SECONDS < DIFF_SECONDS_OLD_CYCLE)); then
                if ((DIFF_SECONDS_OLD_CYCLE > RECOVER_MAX_SECONDS)); then
                    RECOVER_MAX_SECONDS=$DIFF_SECONDS_OLD_CYCLE
                    echo "Jormungandr synchronized, new record of recovery from time difference $DIFF_SECONDS_OLD_CYCLE seconds! Time difference now $DIFF_SECONDS seconds. Last block height $LAST_BLOCK_HEIGHT."
                  else
                   echo "Jormungandr synchronized, recovered from time difference $DIFF_SECONDS_OLD_CYCLE seconds. Time difference now $DIFF_SECONDS seconds. Last block height $LAST_BLOCK_HEIGHT."
                fi
              else
                echo "Jormungandr synchronized. Time difference of $DIFF_SECONDS seconds. Last block height $LAST_BLOCK_HEIGHT."
            fi
         fi
    else
        BOOTSTRAP_ELAPSED_TIME=$(($SECONDS - $BOOTSTRAP_TIME))
        if ((BOOTSTRAP_ELAPSED_TIME > BOOTSTRAP_TOLERANCE_SECONDS)); then
          echo "Jormungandr stuck in bootstrap or offline too long. Attempting to restart node..."
          systemctl stop <jormungandr.service>
          sleep 5
          systemctl start <jormungandr.service>
          BOOTSTRAP_TIME=$SECONDS
       else
          echo "Jormungandr node is offline or bootstrapping since $BOOTSTRAP_ELAPSED_TIME..."
       fi
    fi

    if ((DIFF_SECONDS > 0)); then
      DIFF_SECONDS_OLD_CYCLE=$DIFF_SECONDS
    fi
    sleep $POLLING_INTERVAL_SECONDS
done
