#!/bin/bash

# Script to ensure ALL test products are removed from the database
# Run this after running tests to make sure no test products remain

echo "🧹 Performing comprehensive test product cleanup..."

# Function to execute SQL
execute_sql() {
  if docker-compose ps &>/dev/null; then
    echo "Using docker-compose environment"
    docker-compose exec db psql -U postgres -d postgres -f "/var/lib/postgresql/app/$1"
  else
    # Get database connection details from environment variables if available
    DB_NAME=${DB_NAME:-"postgres"}
    DB_USER=${DB_USER:-"postgres"}
    DB_HOST=${DB_HOST:-"localhost"}
    
    echo "Using direct database connection to $DB_HOST as $DB_USER"
    
    # If PGPASSWORD is not set, ask for it
    if [ -z "$PGPASSWORD" ]; then
      echo "Enter database password for $DB_USER:"
      read -s PGPASSWORD
      export PGPASSWORD
    fi
    
    # Run the SQL file
    psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$1"
  fi
}

# Run the cleanup SQL
execute_sql "cleanup_all_test_products.sql"

# Check if the operation was successful
if [ $? -eq 0 ]; then
  echo "✅ All test products have been successfully removed!"
  exit 0
else
  echo "❌ Failed to remove all test products. Check database connection and permissions."
  exit 1
fi 