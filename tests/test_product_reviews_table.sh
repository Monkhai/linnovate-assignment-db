#!/bin/bash
set -e

echo "Testing product_reviews table..."

# Function to run a SQL query and capture the output
run_query() {
  docker exec -i $(docker-compose ps -q db) psql -U test_user -d test_db -t -c "$1"
}

# Function to run a query that might fail and capture the result
run_query_with_error_check() {
  # Run the query and capture both output and error code
  if docker exec -i $(docker-compose ps -q db) psql -U test_user -d test_db -t -c "$1" &> /dev/null; then
    echo "SUCCESS"  # Query succeeded
  else
    echo "ERROR"    # Query failed
  fi
}

# Test 1: Check if product_reviews table exists
echo "Test 1: Checking if product_reviews table exists..."
TABLE_EXISTS=$(run_query "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'product_reviews');")
if [[ $TABLE_EXISTS == *"t"* ]]; then
  echo "✓ Test passed: product_reviews table exists"
else
  echo "✗ Test failed: product_reviews table does not exist"
  exit 1
fi

# Test 2: Check if all required columns exist
echo "Test 2: Checking if all required columns exist..."
COLUMNS=$(run_query "SELECT column_name FROM information_schema.columns WHERE table_name = 'product_reviews' ORDER BY ordinal_position;")

# Define expected columns
EXPECTED_COLUMNS=("id" "product_id" "review_id" "created_at")

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
ID_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'product_reviews' AND column_name = 'id';")
if [[ $ID_TYPE == *"integer"* ]]; then
  echo "✓ Column 'id' has correct type: integer"
else
  echo "✗ Test failed: Column 'id' has incorrect type: $ID_TYPE"
  exit 1
fi

# Check product_id column type
PRODUCT_ID_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'product_reviews' AND column_name = 'product_id';")
if [[ $PRODUCT_ID_TYPE == *"integer"* ]]; then
  echo "✓ Column 'product_id' has correct type: integer"
else
  echo "✗ Test failed: Column 'product_id' has incorrect type: $PRODUCT_ID_TYPE"
  exit 1
fi

# Check review_id column type
REVIEW_ID_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'product_reviews' AND column_name = 'review_id';")
if [[ $REVIEW_ID_TYPE == *"integer"* ]]; then
  echo "✓ Column 'review_id' has correct type: integer"
else
  echo "✗ Test failed: Column 'review_id' has incorrect type: $REVIEW_ID_TYPE"
  exit 1
fi

# Check created_at column type
CREATED_AT_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'product_reviews' AND column_name = 'created_at';")
if [[ $CREATED_AT_TYPE == *"timestamp with time zone"* ]]; then
  echo "✓ Column 'created_at' has correct type: timestamp with time zone"
else
  echo "✗ Test failed: Column 'created_at' has incorrect type: $CREATED_AT_TYPE"
  exit 1
fi

# Test 4: Check not null constraints
echo "Test 4: Checking NOT NULL constraints..."

# Check product_id not null constraint
PRODUCT_ID_NULLABLE=$(run_query "SELECT is_nullable FROM information_schema.columns WHERE table_name = 'product_reviews' AND column_name = 'product_id';")
if [[ $PRODUCT_ID_NULLABLE == *"NO"* ]]; then
  echo "✓ Column 'product_id' has NOT NULL constraint"
else
  echo "✗ Test failed: Column 'product_id' missing NOT NULL constraint"
  exit 1
fi

# Check review_id not null constraint
REVIEW_ID_NULLABLE=$(run_query "SELECT is_nullable FROM information_schema.columns WHERE table_name = 'product_reviews' AND column_name = 'review_id';")
if [[ $REVIEW_ID_NULLABLE == *"NO"* ]]; then
  echo "✓ Column 'review_id' has NOT NULL constraint"
else
  echo "✗ Test failed: Column 'review_id' missing NOT NULL constraint"
  exit 1
fi

# Test 5: Check foreign key constraints
echo "Test 5: Checking foreign key constraints..."

# Check product_id foreign key
PRODUCT_FK=$(run_query "SELECT EXISTS (
  SELECT 1 FROM information_schema.table_constraints tc
  JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
  WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'product_reviews'
  AND ccu.table_name = 'products'
  AND ccu.column_name = 'id'
);")
if [[ $PRODUCT_FK == *"t"* ]]; then
  echo "✓ Column 'product_id' has foreign key constraint to products.id"
else
  echo "✗ Test failed: Column 'product_id' missing foreign key constraint to products.id"
  exit 1
fi

# Check review_id foreign key
REVIEW_FK=$(run_query "SELECT EXISTS (
  SELECT 1 FROM information_schema.table_constraints tc
  JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
  WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'product_reviews'
  AND ccu.table_name = 'reviews'
  AND ccu.column_name = 'id'
);")
if [[ $REVIEW_FK == *"t"* ]]; then
  echo "✓ Column 'review_id' has foreign key constraint to reviews.id"
else
  echo "✗ Test failed: Column 'review_id' missing foreign key constraint to reviews.id"
  exit 1
fi

# Test 6: Test functionality by creating product, review, and linking them
echo "Test 6: Testing functionality by creating product, review, and linking them..."

# Create a test product
echo "Creating test product..."
run_query "INSERT INTO products (name, price) VALUES ('Test Product', 99.99);"
PRODUCT_ID=$(run_query "SELECT id FROM products WHERE name = 'Test Product';")
PRODUCT_ID=$(echo $PRODUCT_ID | xargs) # Trim whitespace
echo "✓ Created product with ID: $PRODUCT_ID"

# Create a test review
echo "Creating test review..."
run_query "INSERT INTO reviews (user_id, review_title, review_content, stars) VALUES ('test_user', 'Great Product', 'This product is amazing!', 5);"
REVIEW_ID=$(run_query "SELECT id FROM reviews WHERE review_title = 'Great Product';")
REVIEW_ID=$(echo $REVIEW_ID | xargs) # Trim whitespace
echo "✓ Created review with ID: $REVIEW_ID"

# Link product and review in product_reviews table
echo "Linking product and review..."
run_query "INSERT INTO product_reviews (product_id, review_id) VALUES ($PRODUCT_ID, $REVIEW_ID);"
echo "✓ Linked product and review in product_reviews table"

# Verify the link was created
LINK_EXISTS=$(run_query "SELECT EXISTS (SELECT FROM product_reviews WHERE product_id = $PRODUCT_ID AND review_id = $REVIEW_ID);")
if [[ $LINK_EXISTS == *"t"* ]]; then
  echo "✓ Successfully verified link between product and review"
else
  echo "✗ Test failed: Could not verify link between product and review"
  exit 1
fi

# Test 7: Test foreign key constraints by trying to insert non-existent product_id
echo "Test 7: Testing foreign key constraint for product_id..."
NON_EXISTENT_PRODUCT_ID=$((PRODUCT_ID + 999))
FK_TEST_PRODUCT=$(run_query_with_error_check "INSERT INTO product_reviews (product_id, review_id) VALUES ($NON_EXISTENT_PRODUCT_ID, $REVIEW_ID);")
if [[ $FK_TEST_PRODUCT == "ERROR" ]]; then
  echo "✓ Correctly rejected non-existent product_id"
else
  echo "✗ Test failed: Allowed non-existent product_id"
  # Clean up if it somehow succeeded
  run_query "DELETE FROM product_reviews WHERE product_id = $NON_EXISTENT_PRODUCT_ID;"
  exit 1
fi

# Test 8: Test foreign key constraints by trying to insert non-existent review_id
echo "Test 8: Testing foreign key constraint for review_id..."
NON_EXISTENT_REVIEW_ID=$((REVIEW_ID + 999))
FK_TEST_REVIEW=$(run_query_with_error_check "INSERT INTO product_reviews (product_id, review_id) VALUES ($PRODUCT_ID, $NON_EXISTENT_REVIEW_ID);")
if [[ $FK_TEST_REVIEW == "ERROR" ]]; then
  echo "✓ Correctly rejected non-existent review_id"
else
  echo "✗ Test failed: Allowed non-existent review_id"
  # Clean up if it somehow succeeded
  run_query "DELETE FROM product_reviews WHERE review_id = $NON_EXISTENT_REVIEW_ID;"
  exit 1
fi

# Clean up test data
echo "Cleaning up test data..."
run_query "DELETE FROM product_reviews WHERE product_id = $PRODUCT_ID AND review_id = $REVIEW_ID;"
run_query "DELETE FROM reviews WHERE id = $REVIEW_ID;"
run_query "DELETE FROM products WHERE id = $PRODUCT_ID;"

echo "All product_reviews table tests passed successfully! ✅" 