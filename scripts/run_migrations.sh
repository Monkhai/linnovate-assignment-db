#!/bin/bash
set -e

echo "Running migrations..."

# Look for all migration files in the migrations directory and run them in order
for migration in $(ls -1 migrations/*.up.sql | sort); do
  echo "Running migration: $migration"
  # Run the migration
  docker exec -i $(docker-compose ps -q db) psql -U test_user -d test_db < $migration
  echo "Completed migration: $migration"
done

echo "All migrations completed successfully!" 