#!/bin/bash
set -e

echo "Testing reviews table..."

# Function to run a SQL query and capture the output
run_query() {
  docker exec -i $(docker-compose ps -q db) psql -U postgres -d postgres -t -c "$1"
}

# Function to run a query that might fail and capture the result
run_query_with_error_check() {
  # Run the query and capture both output and error code
  if docker exec -i $(docker-compose ps -q db) psql -U postgres -d postgres -t -c "$1" &> /dev/null; then
    echo "SUCCESS"  # Query succeeded
  else
    echo "ERROR"    # Query failed
  fi
}

# Test 1: Check if reviews table exists
echo "Test 1: Checking if reviews table exists..."
TABLE_EXISTS=$(run_query "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'reviews');")
if [[ $TABLE_EXISTS == *"t"* ]]; then
  echo "✓ Test passed: Reviews table exists"
else
  echo "✗ Test failed: Reviews table does not exist"
  exit 1
fi

# Test 2: Check if all required columns exist
echo "Test 2: Checking if all required columns exist..."
COLUMNS=$(run_query "SELECT column_name FROM information_schema.columns WHERE table_name = 'reviews' ORDER BY ordinal_position;")

# Define expected columns
EXPECTED_COLUMNS=("id" "user_id" "product_id" "review_title" "review_content" "stars" "created_at")

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
ID_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'id';")
if [[ $ID_TYPE == *"integer"* ]]; then
  echo "✓ Column 'id' has correct type: integer"
else
  echo "✗ Test failed: Column 'id' has incorrect type: $ID_TYPE"
  exit 1
fi

# Check user_id column type
USER_ID_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'user_id';")
if [[ $USER_ID_TYPE == *"character varying"* ]]; then
  echo "✓ Column 'user_id' has correct type: character varying"
else
  echo "✗ Test failed: Column 'user_id' has incorrect type: $USER_ID_TYPE"
  exit 1
fi

# Check product_id column type
PRODUCT_ID_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'product_id';")
if [[ $PRODUCT_ID_TYPE == *"integer"* ]]; then
  echo "✓ Column 'product_id' has correct type: integer"
else
  echo "✗ Test failed: Column 'product_id' has incorrect type: $PRODUCT_ID_TYPE"
  exit 1
fi

# Check review_title column type
TITLE_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'review_title';")
if [[ $TITLE_TYPE == *"character varying"* ]]; then
  echo "✓ Column 'review_title' has correct type: character varying"
else
  echo "✗ Test failed: Column 'review_title' has incorrect type: $TITLE_TYPE"
  exit 1
fi

# Check review_content column type
CONTENT_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'review_content';")
if [[ $CONTENT_TYPE == *"text"* ]]; then
  echo "✓ Column 'review_content' has correct type: text"
else
  echo "✗ Test failed: Column 'review_content' has incorrect type: $CONTENT_TYPE"
  exit 1
fi

# Check stars column type
STARS_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'stars';")
if [[ $STARS_TYPE == *"integer"* ]]; then
  echo "✓ Column 'stars' has correct type: integer"
else
  echo "✗ Test failed: Column 'stars' has incorrect type: $STARS_TYPE"
  exit 1
fi

# Check created_at column type
CREATED_AT_TYPE=$(run_query "SELECT data_type FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'created_at';")
if [[ $CREATED_AT_TYPE == *"timestamp with time zone"* ]]; then
  echo "✓ Column 'created_at' has correct type: timestamp with time zone"
else
  echo "✗ Test failed: Column 'created_at' has incorrect type: $CREATED_AT_TYPE"
  exit 1
fi

# Test for product_id foreign key constraint
echo "Test: Verifying product_id foreign key constraint..."
# First, create a clean test product for testing
run_query "DELETE FROM products WHERE name = 'Test Product';"
PRODUCT_ID=$(run_query "INSERT INTO products (name, price) VALUES ('Test Product', 29.99) RETURNING id;")
# Simplify extraction - use sed to get just the first number
PRODUCT_ID=$(echo "$PRODUCT_ID" | sed -n 's/[^0-9]*\([0-9][0-9]*\).*/\1/p' | head -1)
echo "Created test product with ID: $PRODUCT_ID"

# Try inserting a review with a valid product_id
echo "Trying to insert a review with valid product_id..."
VALID_INSERT_QUERY="INSERT INTO reviews (user_id, product_id, review_title, review_content, stars) VALUES ('test_user', $PRODUCT_ID, 'Test Review', 'This is a test review', 5);"
echo "Running query: $VALID_INSERT_QUERY"
VALID_INSERT=$(run_query_with_error_check "$VALID_INSERT_QUERY")
echo "Result: $VALID_INSERT"
if [[ $VALID_INSERT == "SUCCESS" ]]; then
  echo "✓ Test passed: Successfully inserted review with valid product_id"
else
  echo "✗ Test failed: Could not insert review with valid product_id"
  run_query "SELECT * FROM products WHERE id = $PRODUCT_ID;" | cat
  exit 1
fi

# Try inserting a review with an invalid product_id
echo "Trying to insert a review with invalid product_id..."
INVALID_ID=999999
INVALID_INSERT_QUERY="INSERT INTO reviews (user_id, product_id, review_title, review_content, stars) VALUES ('test_user', $INVALID_ID, 'Test Review', 'This is a test review', 5);"
echo "Running query: $INVALID_INSERT_QUERY"
INVALID_INSERT=$(run_query_with_error_check "$INVALID_INSERT_QUERY")
echo "Result: $INVALID_INSERT"
if [[ $INVALID_INSERT == "ERROR" ]]; then
  echo "✓ Test passed: Properly rejected review with invalid product_id"
else
  echo "✗ Test failed: Accepted review with invalid product_id"
  exit 1
fi

# Test 4: Check not null constraints
echo "Test 4: Checking NOT NULL constraints..."

# Check user_id not null constraint
USER_ID_NULLABLE=$(run_query "SELECT is_nullable FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'user_id';")
if [[ $USER_ID_NULLABLE == *"NO"* ]]; then
  echo "✓ Column 'user_id' has NOT NULL constraint"
else
  echo "✗ Test failed: Column 'user_id' missing NOT NULL constraint"
  exit 1
fi

# Check product_id not null constraint
PRODUCT_ID_NULLABLE=$(run_query "SELECT is_nullable FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'product_id';")
if [[ $PRODUCT_ID_NULLABLE == *"NO"* ]]; then
  echo "✓ Column 'product_id' has NOT NULL constraint"
else
  echo "✗ Test failed: Column 'product_id' missing NOT NULL constraint"
  exit 1
fi

# Check review_title not null constraint
TITLE_NULLABLE=$(run_query "SELECT is_nullable FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'review_title';")
if [[ $TITLE_NULLABLE == *"NO"* ]]; then
  echo "✓ Column 'review_title' has NOT NULL constraint"
else
  echo "✗ Test failed: Column 'review_title' missing NOT NULL constraint"
  exit 1
fi

# Check review_content not null constraint
CONTENT_NULLABLE=$(run_query "SELECT is_nullable FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'review_content';")
if [[ $CONTENT_NULLABLE == *"NO"* ]]; then
  echo "✓ Column 'review_content' has NOT NULL constraint"
else
  echo "✗ Test failed: Column 'review_content' missing NOT NULL constraint"
  exit 1
fi

# Check stars not null constraint
STARS_NULLABLE=$(run_query "SELECT is_nullable FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'stars';")
if [[ $STARS_NULLABLE == *"NO"* ]]; then
  echo "✓ Column 'stars' has NOT NULL constraint"
else
  echo "✗ Test failed: Column 'stars' missing NOT NULL constraint"
  exit 1
fi

# Test 5: Check stars constraint (1-5)
echo "Test 5: Checking stars constraint (1-5)..."

# Try to insert a value below the allowed range
echo "Trying to insert a review with stars = 0 (should fail)..."
INSERT_BELOW_RANGE=$(run_query_with_error_check "INSERT INTO reviews (user_id, product_id, review_title, review_content, stars) VALUES ('test_user', $PRODUCT_ID, 'Test Title', 'Test Content', 0);")
if [[ $INSERT_BELOW_RANGE == "ERROR" ]]; then
  echo "✓ Correctly rejected stars value below range (0)"
else
  echo "✗ Test failed: Allowed stars value below range (0)"
  # Clean up if it somehow succeeded
  run_query "DELETE FROM reviews WHERE user_id = 'test_user' AND stars = 0;"
  exit 1
fi

# Try to insert a value above the allowed range
echo "Trying to insert a review with stars = 6 (should fail)..."
INSERT_ABOVE_RANGE=$(run_query_with_error_check "INSERT INTO reviews (user_id, product_id, review_title, review_content, stars) VALUES ('test_user', $PRODUCT_ID, 'Test Title', 'Test Content', 6);")
if [[ $INSERT_ABOVE_RANGE == "ERROR" ]]; then
  echo "✓ Correctly rejected stars value above range (6)"
else
  echo "✗ Test failed: Allowed stars value above range (6)"
  # Clean up if it somehow succeeded
  run_query "DELETE FROM reviews WHERE user_id = 'test_user' AND stars = 6;"
  exit 1
fi

# Test 6: Test table functionality by inserting and retrieving valid data
echo "Test 6: Testing functionality by inserting and retrieving valid data..."

# Insert valid test reviews with different star ratings
for stars in {1..5}; do
  run_query "INSERT INTO reviews (user_id, product_id, review_title, review_content, stars) VALUES ('test_user', $PRODUCT_ID, 'Test Title $stars', 'Test Content $stars', $stars);"
  echo "✓ Successfully inserted review with $stars stars"
done

# Retrieve and verify the reviews
for stars in {1..5}; do
  REVIEW=$(run_query "SELECT review_title, stars FROM reviews WHERE review_title = 'Test Title $stars';")
  if [[ $REVIEW == *"Test Title $stars"* && $REVIEW == *"$stars"* ]]; then
    echo "✓ Successfully retrieved review with $stars stars"
  else
    echo "✗ Test failed: Could not retrieve review with $stars stars"
    exit 1
  fi
done

# Clean up test data
run_query "DELETE FROM reviews WHERE user_id = 'test_user';"

echo "All reviews table tests passed successfully! ✅" 