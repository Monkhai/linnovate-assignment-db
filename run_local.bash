#!/bin/bash
set -e

echo "=== Starting Database Setup and Tests ==="

# Step 1: Set up the database
echo "Step 1: Setting up the database..."
./scripts/setup_db.sh

# Step 2: Run migrations
echo "Step 2: Running migrations..."
./scripts/run_migrations.sh

# Step 3: Run tests
echo "Step 3: Running tests..."
./scripts/run_tests.sh

# Step 4: Connect to the database
echo "Step 4: Connecting to the database..."
echo "To exit the PostgreSQL terminal, type: \q"
echo "-----------------------------------------"
docker exec -it $(docker-compose ps -q db) psql -U postgres -d postgres 