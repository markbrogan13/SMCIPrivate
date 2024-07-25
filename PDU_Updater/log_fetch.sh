#!/bin/bash

# Variables
BASE_IP="192.64.198"
START=1
FINISH=144
USERNAME="admin"
PASSWORD="raritan"
PWD="/home/test/PDU_Logs/"
COMMAND1="show eventlog class pdu"

for i in $(seq $START $FINISH); do
    PDU_IP="$BASE_IP.$i"
    OUTPUT_FILE="$PWD/$PDU_IP"
    # Execute SSH command and save output to file
    sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$PDU_IP > $OUTPUT_FILE
$COMMAND1
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "Event log successfully saved to $OUTPUT_FILE"
    else
        echo "Failed to retrieve event log"
    fi
done