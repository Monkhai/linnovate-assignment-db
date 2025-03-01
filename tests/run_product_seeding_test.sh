#!/bin/bash

# Set database connection parameters
# Replace these with your actual database connection details
DB_NAME="your_database_name"
DB_USER="your_database_user"
DB_PASSWORD="your_database_password"
DB_HOST="localhost"

echo "Running product seeding test..."

# Run the test SQL script and capture its output
RESULT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$(dirname "$0")/test_products_seeding.sql" 2>&1)

# Check if the test reported any failures
if echo "$RESULT" | grep -q "TEST FAILED"; then
  echo "$RESULT"
  echo "❌ Test failed!"
  exit 1
else
  echo "$RESULT"
  echo "✅ Test passed! Products were seeded successfully."
  exit 0
fi 