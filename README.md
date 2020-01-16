# Helper scripts to run a Stakepool node

stuck_check.sh - Will restart node when a "stuck_notifier" is thrown\
                 In node-config you can define the time threshold when you want the node to throw the stuck_notifier\
                 E.g. "no_blockchain_updates_warning_interval: 5m" (default is 30m)
                 Assumption: systemctl is used to start jormungandr node.\
                 Replace all <> placeholders to match your setup.
                 
                

jormon.sh - Based on the more aggressive restart script from Michael Fazio (sandstone.io)\
            With a twist: This update now also considers a node stuck if it is too long offline or in bootstrap mode.\
            Additional features: Improved logging.\
            Assumption: systemctl is used to start jormungandr node\
            Replace all <> placeholders to match your setup
            Known issues: If timing is unlucky and no new block is received between bootstrap end and next polling after a restart, the bootstrap time will be added to the already overflown time intervall and another restart will the triggered potentially causing a restart loop
