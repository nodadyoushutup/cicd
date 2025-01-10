#!/bin/bash

# Set environment variables
if [ -f .env ]; then
  set -a # Automatically export all variables
  source .env
  set +a
else
  echo "Error: .env file not found."
  exit 1
fi

# Export PGPASSWORD to avoid password prompt
export PGPASSWORD="$PG_PASSWORD"

# Step 1: Check if the role exists and create it if necessary
ROLE_EXISTS=$(psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$PG_DB" -tAc "SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = '${JENKINS_PG_ROLE}'")

if [[ "$ROLE_EXISTS" != "1" ]]; then
  echo "Creating role ${JENKINS_PG_ROLE}..."
  psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$PG_DB" -c "CREATE ROLE ${JENKINS_PG_ROLE} WITH LOGIN PASSWORD '${JENKINS_PG_PASSWORD}';"
else
  echo "Role ${JENKINS_PG_ROLE} already exists."
fi

# Step 2: Check if the database exists and create it if necessary
DB_EXISTS=$(psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$PG_DB" -tAc "SELECT 1 FROM pg_database WHERE datname = '${JENKINS_PG_DB}'")

if [[ "$DB_EXISTS" != "1" ]]; then
  echo "Creating database ${JENKINS_PG_DB}..."
  psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$PG_DB" -c "CREATE DATABASE ${JENKINS_PG_DB} OWNER ${JENKINS_PG_ROLE};"
else
  echo "Database ${JENKINS_PG_DB} already exists."
fi

# Step 3: Grant privileges on the database
echo "Granting privileges on database ${JENKINS_PG_DB} to role ${JENKINS_PG_ROLE}..."
psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$JENKINS_PG_DB" -c "
GRANT ALL PRIVILEGES ON DATABASE ${JENKINS_PG_DB} TO ${JENKINS_PG_ROLE};
"

# Step 4: Grant object privileges in the jenkins database
psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$JENKINS_PG_DB" -c "
GRANT ALL PRIVILEGES ON SCHEMA public TO ${JENKINS_PG_ROLE};
"

psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$JENKINS_PG_DB" -c "
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${JENKINS_PG_ROLE};
"

psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$JENKINS_PG_DB" -c "
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${JENKINS_PG_ROLE};
"

psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$JENKINS_PG_DB" -c "
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO ${JENKINS_PG_ROLE};
"

echo "Jenkins role and database setup complete!"

# Unset PGPASSWORD for security
unset PGPASSWORD
