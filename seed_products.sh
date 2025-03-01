#!/bin/bash

# Set database connection parameters
# Replace these with your actual database connection details
DB_NAME="your_database_name"
DB_USER="your_database_user"
DB_PASSWORD="your_database_password"
DB_HOST="localhost"

echo "Seeding products directly..."

# Run the seeding SQL script
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "seed_products_direct.sql"

# Check if seeding was successful
if [ $? -eq 0 ]; then
  echo "✅ Products seeded successfully!"
  
  # Run the test to verify
  echo "Running verification test..."
  RESULT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "tests/test_products_seeding.sql" 2>&1)
  
  # Check if the test reported any failures
  if echo "$RESULT" | grep -q "FAILED"; then
    echo "$RESULT"
    echo "❌ Verification test failed!"
    exit 1
  else
    echo "$RESULT"
    echo "✅ Verification test passed!"
    exit 0
  fi
else
  echo "❌ Failed to seed products!"
  exit 1
fi 