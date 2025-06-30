#!/bin/sh
SECRET_FILE=/run/secrets/jenkins-agent-secret
# Wait for the controller to write the secret
while [ ! -s "$SECRET_FILE" ]; do
  echo "Waiting for agent secret..."
  sleep 2
done
export JENKINS_SECRET="$(cat $SECRET_FILE)"
exec jenkins-agent
