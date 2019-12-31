#Helper scripts to run a Stakepool node

stuck_check.sh - run with sudo, will restart node when a "stuck_notifier" is thrown\
                 Assumption: systemctl is used to start jormungandr node.\
                 Replace all <> placeholders to match your setup.
                 
                 

jormon.sh - Based on the more aggressive restart script from Michael Fazio (sandstone.io)\
            With a twist: This update now also considers a node stuck if it is too long offline or in bootstrap mode.\
            Assumption: systemctl is used to start jormungandr node\
            Replace all <> placeholders to match your setup
