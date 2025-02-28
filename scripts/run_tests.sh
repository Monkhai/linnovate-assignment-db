#!/bin/bash
set -e

echo "Running database tests..."

# Run all test scripts in the tests directory
for test_script in $(ls -1 tests/*.sh | sort); do
  echo "====================================="
  echo "Running test script: $test_script"
  bash $test_script
  
  # Check if the test script was successful
  if [ $? -eq 0 ]; then
    echo "Test script completed successfully: $test_script"
  else
    echo "Test script failed: $test_script"
    exit 1
  fi
  echo "====================================="
done

echo "All tests completed successfully! ✅" 