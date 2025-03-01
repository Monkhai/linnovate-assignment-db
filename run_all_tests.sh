#!/bin/bash

# Comprehensive test runner that ensures proper cleanup after tests

echo "=== 🧪 Running all database tests 🧪 ==="
echo

# Track test results
ALL_TESTS_PASSED=true

# Function to run a test
run_test() {
  echo "⏳ Running test: $1..."
  
  # Run the test
  if bash "$1"; then
    echo "✅ Test passed: $1"
    echo
    return 0
  else
    echo "❌ Test failed: $1"
    echo
    ALL_TESTS_PASSED=false
    return 1
  fi
}

# Function to run a SQL test
run_sql_test() {
  echo "⏳ Running SQL test: $1..."
  
  # Function to execute SQL
  if docker-compose ps &>/dev/null; then
    docker-compose exec db psql -U postgres -d postgres -f "/var/lib/postgresql/app/$1"
  else
    # Get database connection details from environment variables if available
    DB_NAME=${DB_NAME:-"postgres"}
    DB_USER=${DB_USER:-"postgres"}
    DB_HOST=${DB_HOST:-"localhost"}
    
    # Run the SQL file
    PGPASSWORD=${PGPASSWORD} psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$1" 
  fi
  
  # Check result
  if [ $? -eq 0 ]; then
    echo "✅ SQL test passed: $1"
    echo
    return 0
  else
    echo "❌ SQL test failed: $1"
    echo
    ALL_TESTS_PASSED=false
    return 1
  fi
}

# Clean database and seed initial products
echo "🔄 Resetting database to known state..."
./reset_products.sh
echo

# Run all shell script tests
run_test "tests/test_products_table.sh"
run_test "tests/test_reviews_table.sh"

# Run all SQL tests
run_sql_test "tests/test_products_seeding.sql"

# IMPORTANT: Run cleanup regardless of test results
echo "🧹 Cleaning up any test products..."
./cleanup_all_test_products.sh

# Verify final state
echo "🔍 Verifying final database state..."
run_sql_test "tests/test_products_seeding.sql"

# Final result
echo "=== 🏁 Test Summary 🏁 ==="
if [ "$ALL_TESTS_PASSED" = true ]; then
  echo "✅ All tests passed!"
  exit 0
else
  echo "❌ Some tests failed. See above for details."
  exit 1
fi 