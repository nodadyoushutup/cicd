#!/usr/bin/env bash

# Example usage: ./get_secret.sh <host> <user> <private_key_file>

HOST="$1"
USER="$2"
KEY="$3"

SECRET_VALUE=$(ssh -o StrictHostKeyChecking=no -i "$KEY" "$USER@$HOST" \
    cat /home/ubuntu/.secret/agent_secret.txt 2>/dev/null)

# Return in JSON format
echo "{\"secret\": \"${SECRET_VALUE}\"}"
