#!/bin/bash

# Simple script to test database connectivity with various options

echo "=== PostgreSQL Connection Test ==="
echo ""

# First, check networking basics
echo "Testing basic network connectivity..."
echo "Pinging database endpoint..."
ping -c 2 test-database.cbqgq6yw4uxd.eu-north-1.rds.amazonaws.com
echo ""

echo "Testing port connectivity with netcat..."
nc -zv test-database.cbqgq6yw4uxd.eu-north-1.rds.amazonaws.com 5432 -w 5
echo ""

# Now test PostgreSQL connection
echo "Trying PostgreSQL connection..."
read -s -p "Enter database password: " DB_PASSWORD
echo ""

# Try multiple connection attempts with different options
echo "Attempt 1: Standard connection..."
PGCONNECT_TIMEOUT=5 PGPASSWORD=$DB_PASSWORD psql -h test-database.cbqgq6yw4uxd.eu-north-1.rds.amazonaws.com -p 5432 -U postgres -d postgres -c "SELECT 1" 2>&1

echo "Attempt 2: Verbose connection..."
PGCONNECT_TIMEOUT=5 PGPASSWORD=$DB_PASSWORD psql -v ON_ERROR_STOP=1 -h test-database.cbqgq6yw4uxd.eu-north-1.rds.amazonaws.com -p 5432 -U postgres -d postgres -c "SELECT 1" 2>&1

echo "Attempt 3: With different database name..."
PGCONNECT_TIMEOUT=5 PGPASSWORD=$DB_PASSWORD psql -h test-database.cbqgq6yw4uxd.eu-north-1.rds.amazonaws.com -p 5432 -U postgres -d test-database -c "SELECT 1" 2>&1

echo ""
echo "=== Connection Tests Complete ==="

echo ""
echo "If all tests failed, check:"
echo "1. Your password is correct"
echo "2. Security Group has an inbound rule for your IP ($(curl -s https://checkip.amazonaws.com || echo 'unknown')) on port 5432"
echo "3. The RDS instance is publicly accessible"
echo "4. The RDS instance is in 'Available' state (not in maintenance)"
echo "5. Your AWS CLI profile has correct region set"
echo "6. There is no VPC endpoint policy restricting access" 