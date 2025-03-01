#!/bin/bash

# Simple script to reset and seed products using the migration file
echo "🔄 Resetting and seeding products table..."

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

# Run the seed products migration directly
execute_sql "migrations/003_seed_products.up.sql"

# Check if the operation was successful
if [ $? -eq 0 ]; then
  echo "✅ Products have been successfully reset and seeded!"
  
  # Run the test to verify
  echo "Running verification test..."
  execute_sql "tests/test_products_seeding.sql"
  
  # Check if the test reported any failures
  if [ $? -ne 0 ]; then
    echo "❌ Verification test failed!"
    exit 1
  else
    echo "✅ Verification test passed! Products have been properly reset."
    exit 0
  fi
else
  echo "❌ Failed to reset products. Check database connection and permissions."
  exit 1
fi 