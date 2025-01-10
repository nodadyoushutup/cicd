#!/bin/bash

# Set environment variables
PG_USER="postgres"        # The admin user for PostgreSQL
PG_PASSWORD="postgres"    # Password for the admin user
PG_HOST="192.168.1.101"   # Host where PostgreSQL is running
PG_PORT="5432"            # PostgreSQL port
PG_DB="postgres"          # Default database to connect initially
JENKINS_DB="jenkins"      # Database to be created
JENKINS_ROLE="jenkins"    # Role to be created
JENKINS_PASSWORD="jenkins" # Password for the jenkins role

# Export PGPASSWORD to avoid password prompt
export PGPASSWORD="$PG_PASSWORD"

# Step 1: Check if the role exists and create it if necessary
ROLE_EXISTS=$(psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$PG_DB" -tAc "SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = '${JENKINS_ROLE}'")

if [[ "$ROLE_EXISTS" != "1" ]]; then
  echo "Creating role ${JENKINS_ROLE}..."
  psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$PG_DB" -c "CREATE ROLE ${JENKINS_ROLE} WITH LOGIN PASSWORD '${JENKINS_PASSWORD}';"
else
  echo "Role ${JENKINS_ROLE} already exists."
fi

# Step 2: Check if the database exists and create it if necessary
DB_EXISTS=$(psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$PG_DB" -tAc "SELECT 1 FROM pg_database WHERE datname = '${JENKINS_DB}'")

if [[ "$DB_EXISTS" != "1" ]]; then
  echo "Creating database ${JENKINS_DB}..."
  psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$PG_DB" -c "CREATE DATABASE ${JENKINS_DB} OWNER ${JENKINS_ROLE};"
else
  echo "Database ${JENKINS_DB} already exists."
fi

# Step 3: Grant privileges on the database
echo "Granting privileges on database ${JENKINS_DB} to role ${JENKINS_ROLE}..."
psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$JENKINS_DB" -c "
GRANT ALL PRIVILEGES ON DATABASE ${JENKINS_DB} TO ${JENKINS_ROLE};
"

# Step 4: Grant object privileges in the jenkins database
psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$JENKINS_DB" -c "
GRANT ALL PRIVILEGES ON SCHEMA public TO ${JENKINS_ROLE};
"

psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$JENKINS_DB" -c "
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${JENKINS_ROLE};
"

psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$JENKINS_DB" -c "
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${JENKINS_ROLE};
"

psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d "$JENKINS_DB" -c "
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO ${JENKINS_ROLE};
"

echo "Jenkins role and database setup complete!"

# Unset PGPASSWORD for security
unset PGPASSWORD
