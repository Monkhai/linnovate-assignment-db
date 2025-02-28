#!/bin/bash
set -e

echo "Starting PostgreSQL database with Docker..."
docker-compose up -d

# Wait for the database to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 5

# Keep trying to connect until successful (maximum 30 seconds)
MAX_TRIES=30
COUNTER=0
until docker exec $(docker-compose ps -q db) pg_isready -U test_user || [ $COUNTER -eq $MAX_TRIES ]; do
  echo "Waiting for PostgreSQL to be ready... ($(( COUNTER + 1 ))/$MAX_TRIES)"
  sleep 1
  COUNTER=$((COUNTER+1))
done

if [ $COUNTER -eq $MAX_TRIES ]; then
  echo "Failed to connect to PostgreSQL within $MAX_TRIES seconds"
  exit 1
fi

echo "PostgreSQL is ready!" 