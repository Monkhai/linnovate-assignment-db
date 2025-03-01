#!/bin/bash

# Set database connection parameters
# Replace these with your actual database connection details
DB_NAME="your_database_name"
DB_USER="your_database_user"
DB_PASSWORD="your_database_password"
DB_HOST="localhost"

echo "Cleaning up test products..."

# Run the cleanup SQL script
RESULT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "cleanup_test_products.sql")

echo "$RESULT"

# Check if there are still test products
if echo "$RESULT" | grep -q "remaining_test_products | 0"; then
  echo "✅ All test products successfully removed."
  exit 0
else
  echo "❌ Failed to remove all test products."
  exit 1
fi 