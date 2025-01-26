#!/usr/bin/env bash

# Example usage: ./get_secret.sh <host> <user> <private_key_file>

HOST="$1"
USER="$2"
KEY="$3"
PORT="$4"

SECRET_VALUE=$(
  ssh -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o IdentityFile="$KEY" \
  -l "$USER" \
  -p 10122 -- \
  "$$HOST" \
  "cat /home/$USER/secret/jenkins_agent"
 2>/dev/null)
SECRET_VALUE=$(ssh -o StrictHostKeyChecking=no -i "$KEY" "$USER@$HOST" pwd 2>/dev/null)

# Return in JSON format
echo "{\"secret\": \"${SECRET_VALUE}\"}"
