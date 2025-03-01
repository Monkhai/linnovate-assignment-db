#!/bin/bash

# Exit on error
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Running migrations..."
# First run all migrations
"${SCRIPT_DIR}/run_migrations.sh"

echo "Seeding products..."
# Then seed the products table
psql $DATABASE_URL -f "${PROJECT_ROOT}/scripts/seed_products.sql"

echo "Database initialization complete!" 