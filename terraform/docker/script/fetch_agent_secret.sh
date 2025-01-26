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
  -p "$PORT" -- \
  "$$HOST" \
  "cat /home/$USER/secret/jenkins_agent"
)

# Return in JSON format
echo "{\"secret\": \"$KEY\"}"
