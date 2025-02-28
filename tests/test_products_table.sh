#!/bin/bash
set -e

echo "Testing products table..."

# Function to run a SQL query and capture the output
run_query() {
  docker exec -i $(docker-compose ps -q db) psql -U test_user -d test_db -t -c "$1"
}

# Test 1: Check if products table exists
echo "Test 1: Checking if products table exists..."
TABLE_EXISTS=$(run_query "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products');")
if [[ $TABLE_EXISTS == *"t"* ]]; then
  echo "✓ Test passed: Products table exists"
else
  echo "✗ Test failed: Products table does not exist"
  exit 1
fi

# Test 2: Check if all required columns exist
echo "Test 2: Checking if all required columns exist..."
COLUMNS=$(run_query "SELECT column_name FROM information_schema.columns WHERE table_name = 'products' ORDER BY ordinal_position;")

# Define expected columns
EXPECTED_COLUMNS=("id" "name" "price" "created_at")

# Check each expected column
for column in "${EXPECTED_COLUMNS[@]}"; do
  if [[ $COLUMNS == *"$column"* ]]; then
    echo "✓ Column '$column' exists"
  else
    echo "✗ Test failed: Column '$column' does not exist"
    exit 1
  fi
done

# Test 3: Check column data types
echo "Test 3: Checking column data types..."

# Check id column type
ID_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'id';")
if [[ $ID_TYPE == *"integer"* ]]; then
  echo "✓ Column 'id' has correct type: integer"
else
  echo "✗ Test failed: Column 'id' has incorrect type: $ID_TYPE"
  exit 1
fi

# Check name column type
NAME_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'name';")
if [[ $NAME_TYPE == *"character varying"* ]]; then
  echo "✓ Column 'name' has correct type: character varying"
else
  echo "✗ Test failed: Column 'name' has incorrect type: $NAME_TYPE"
  exit 1
fi

# Check price column type
PRICE_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'price';")
if [[ $PRICE_TYPE == *"numeric"* ]]; then
  echo "✓ Column 'price' has correct type: numeric"
else
  echo "✗ Test failed: Column 'price' has incorrect type: $PRICE_TYPE"
  exit 1
fi

# Check created_at column type
CREATED_AT_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'created_at';")
if [[ $CREATED_AT_TYPE == *"timestamp with time zone"* ]]; then
  echo "✓ Column 'created_at' has correct type: timestamp with time zone"
else
  echo "✗ Test failed: Column 'created_at' has incorrect type: $CREATED_AT_TYPE"
  exit 1
fi

# Test 4: Check not null constraints
echo "Test 4: Checking NOT NULL constraints..."

# Check name not null constraint
NAME_NULLABLE=$(run_query "SELECT is_nullable FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'name';")
if [[ $NAME_NULLABLE == *"NO"* ]]; then
  echo "✓ Column 'name' has NOT NULL constraint"
else
  echo "✗ Test failed: Column 'name' missing NOT NULL constraint"
  exit 1
fi

# Check price not null constraint
PRICE_NULLABLE=$(run_query "SELECT is_nullable FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'price';")
if [[ $PRICE_NULLABLE == *"NO"* ]]; then
  echo "✓ Column 'price' has NOT NULL constraint"
else
  echo "✗ Test failed: Column 'price' missing NOT NULL constraint"
  exit 1
fi

# Test 5: Test table functionality by inserting and retrieving a row
echo "Test 5: Testing functionality by inserting and retrieving data..."

# Insert a test product
run_query "INSERT INTO products (name, price) VALUES ('Test Product', 9.99);"

# Retrieve the product
PRODUCT=$(run_query "SELECT name, price FROM products WHERE name = 'Test Product';")
if [[ $PRODUCT == *"Test Product"* && $PRODUCT == *"9.99"* ]]; then
  echo "✓ Successfully inserted and retrieved product"
else
  echo "✗ Test failed: Could not insert or retrieve product"
  exit 1
fi

# Clean up test data
run_query "DELETE FROM products WHERE name = 'Test Product';"

echo "All products table tests passed successfully! ✅" 