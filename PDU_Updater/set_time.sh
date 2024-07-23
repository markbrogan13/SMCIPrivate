#!/bin/bash

# Define variables
BASE_IP="192.64.198"
START=3
FINISH=144
USER="admin"
PASSWORD="raritan"
COMMAND1="config"
COMMAND2="time method manual"
COMMAND4="apply"
COMMAND5="exit"

# Loop through each IP address
for i in $(seq $START $FINISH); do
    # Construct the full IP address
    RARITAN_IP="$BASE_IP.$i"

    # Capture the current time
    CURRENT_TIME=$(TZ="America/Chicago" date +%T)
    COMMAND3="time set time $CURRENT_TIME"

    # Run commands via SSH
    sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USER@$RARITAN_IP << EOF
$COMMAND1
$COMMAND2
$COMMAND3
$COMMAND4
$COMMAND5
EOF

    echo "Commands executed on $RARITAN_IP with time set to $CURRENT_TIME."
done