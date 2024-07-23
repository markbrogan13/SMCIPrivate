#!/bin/bash

# Define variables
RARITAN_IP="192.64.198"
START=1
FINISH=144
USER="admin"
PASSWORD="raritan"
COMMAND1="config"
COMMAND2="time method manual"
COMMAND3="time set date 2024-07-23"
COMMAND4="apply"
COMMAND5="exit"

# Run commands via SSH
for i in $(seq $START $FINISH); do
    sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USER@$RARITAN_IP.$i << EOF
$COMMAND1
$COMMAND2
$COMMAND3
$COMMAND4
$COMMAND5
EOF
done