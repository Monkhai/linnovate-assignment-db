#!/bin/bash
set -e

echo "=== AWS RDS PostgreSQL Database Deployment Script ==="
echo ""

# Function to display usage info
usage() {
  echo "This script helps deploy your database to AWS RDS."
  echo ""
  echo "You'll need the following information:"
  echo "  - AWS Secret Name (if using AWS Secrets Manager for credentials)"
  echo "  - Database connection details (host, port, username, password)"
  echo "  - AWS Region (e.g., us-east-1, eu-north-1)"
  echo ""
}

# Check if required commands exist
check_commands() {
  commands=("psql" "aws")
  
  for cmd in "${commands[@]}"; do
    if ! command -v $cmd &> /dev/null; then
      echo "Error: Required command '$cmd' not found."
      if [ "$cmd" == "aws" ]; then
        echo "Please install the AWS CLI: pip install awscli"
        echo "Then configure with: aws configure"
      elif [ "$cmd" == "psql" ]; then
        echo "Please install PostgreSQL client tools"
      fi
      exit 1
    fi
  done
}

# Get credentials from user or AWS Secrets Manager
get_credentials() {
  echo "How would you like to provide database credentials?"
  echo "1) Use AWS Secrets Manager (for username/password only)"
  echo "2) Enter credentials manually"
  read -p "Choose an option (1 or 2): " cred_option

  if [ "$cred_option" == "1" ]; then
    read -p "Enter AWS Region: " AWS_REGION
    
    echo "Listing available secrets in region $AWS_REGION..."
    SECRET_LIST=$(aws secretsmanager list-secrets --region "$AWS_REGION" --query "SecretList[*].[Name,ARN]" --output text)
    
    if [ -z "$SECRET_LIST" ]; then
      echo "No secrets found in region $AWS_REGION."
      echo "Would you like to manually enter a secret name or switch to manual credentials?"
      echo "1) Manually enter secret name"
      echo "2) Enter credentials manually"
      read -p "Choose an option (1 or 2): " no_secrets_option
      
      if [ "$no_secrets_option" == "1" ]; then
        read -p "Enter AWS Secret Name: " SECRET_NAME
        # Store the ARN directly to avoid issues with special characters
        SECRET_ARN=$(aws secretsmanager list-secrets --region "$AWS_REGION" --query "SecretList[?contains(Name,'${SECRET_NAME}')].ARN" --output text)
        
        if [ -z "$SECRET_ARN" ]; then
          echo "Could not find a secret matching that name."
          echo "Trying direct access with the provided name..."
          SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --region "$AWS_REGION" --query SecretString --output text 2>/dev/null)
          
          if [ $? -ne 0 ]; then
            echo "Error: Could not retrieve the secret. Switching to manual credentials."
            goto_manual_credentials
            return
          fi
        else
          echo "Found matching secret ARN: $SECRET_ARN"
          SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --region "$AWS_REGION" --query SecretString --output text)
        fi
      else
        goto_manual_credentials
        return
      fi
    else
      echo "Available secrets:"
      IFS=$'\n'
      secret_array=($SECRET_LIST)
      unset IFS
      
      for i in "${!secret_array[@]}"; do
        secret_line="${secret_array[$i]}"
        # Split the line by tab character
        secret_name=$(echo "$secret_line" | awk '{print $1}')
        secret_arn=$(echo "$secret_line" | awk '{print $2}')
        echo "$((i+1))) $secret_name"
      done
      
      read -p "Select a secret by number (or enter 'q' to quit): " secret_choice
      
      if [[ "$secret_choice" == "q" ]]; then
        echo "Exiting script."
        exit 0
      fi
      
      if ! [[ "$secret_choice" =~ ^[0-9]+$ ]] || [ "$secret_choice" -lt 1 ] || [ "$secret_choice" -gt "${#secret_array[@]}" ]; then
        echo "Invalid selection. Exiting."
        exit 1
      fi
      
      selected_index=$((secret_choice-1))
      selected_line="${secret_array[$selected_index]}"
      SECRET_ARN=$(echo "$selected_line" | awk '{print $2}')
      
      echo "Retrieving secret using ARN: $SECRET_ARN"
      SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --region "$AWS_REGION" --query SecretString --output text)
      
      if [ $? -ne 0 ]; then
        echo "Error retrieving secret. Please check permissions."
        goto_manual_credentials
        return
      fi
    fi
    
    # Extract username and password from JSON
    if command -v jq &> /dev/null; then
      DB_USER=$(echo $SECRET_JSON | jq -r '.username // .user')
      DB_PASSWORD=$(echo $SECRET_JSON | jq -r '.password')
    else
      # Fallback for systems without jq
      echo "Note: Installing jq would improve secret parsing."
      DB_USER=$(echo $SECRET_JSON | grep -o '"username"[^,]*' | cut -d'"' -f4 2>/dev/null || 
                echo $SECRET_JSON | grep -o '"user"[^,]*' | cut -d'"' -f4)
      DB_PASSWORD=$(echo $SECRET_JSON | grep -o '"password"[^,]*' | cut -d'"' -f4)
    fi
    
    # Always prompt for endpoint information since it's not in the secret
    read -p "Enter RDS Host/Endpoint: " DB_HOST
    read -p "Enter Database Port [5432]: " DB_PORT
    DB_PORT=${DB_PORT:-5432}
    read -p "Enter Database Name [postgres]: " DB_NAME
    DB_NAME=${DB_NAME:-postgres}
  else
    goto_manual_credentials
  fi
  
  # Validate that we have all required credentials
  if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "Error: Missing required database connection details."
    exit 1
  fi
  
  # Display connection info (without password)
  echo ""
  echo "Database connection information:"
  echo "Host: $DB_HOST"
  echo "Port: $DB_PORT"
  echo "User: $DB_USER"
  echo "Database: $DB_NAME"
  echo ""
}

# Function to handle manual credential entry
goto_manual_credentials() {
  read -p "Enter RDS Host/Endpoint: " DB_HOST
  read -p "Enter Database Port [5432]: " DB_PORT
  DB_PORT=${DB_PORT:-5432}
  read -p "Enter Database Username: " DB_USER
  read -s -p "Enter Database Password: " DB_PASSWORD
  echo ""
  read -p "Enter Database Name [postgres]: " DB_NAME
  DB_NAME=${DB_NAME:-postgres}
}

# Test the database connection
test_connection() {
  echo "Testing connection to PostgreSQL database..."
  echo "Attempting to connect to $DB_HOST:$DB_PORT as $DB_USER..."
  
  # First try with a 10-second timeout
  if PGCONNECT_TIMEOUT=10 PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1" > /dev/null 2>&1; then
    echo "Connection successful!"
  else
    echo "Initial connection test failed. Running with verbose output:"
    # Try again with verbose output to see the error
    PGCONNECT_TIMEOUT=10 PGPASSWORD=$DB_PASSWORD psql -v ON_ERROR_STOP=1 -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;"
    
    echo ""
    echo "Error: Could not connect to the database."
    echo "Please check:"
    echo "1. Credentials are correct"
    echo "2. Security group allows connections from IP $(curl -s https://checkip.amazonaws.com || echo 'unknown')"
    echo "3. Database instance is publicly accessible"
    echo "4. Database is not in maintenance or being rebooted"
    
    # Ask if they want to continue anyway
    read -p "Connection failed. Would you like to continue anyway? (y/N): " continue_anyway
    if [[ $continue_anyway =~ ^[Yy]$ ]]; then
      echo "Continuing despite connection failure..."
      return
    else
      exit 1
    fi
  fi
}

# Create the database if it doesn't exist
ensure_database() {
  echo "Checking if database '$DB_NAME' exists..."
  if ! PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1; then
    echo "Database '$DB_NAME' does not exist. Creating..."
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;"
    echo "Database created successfully."
  else
    echo "Database '$DB_NAME' already exists."
    
    read -p "Would you like to reset the database? This will delete all existing data. (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
      echo "Resetting database..."
      PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "DROP TABLE IF EXISTS reviews CASCADE; DROP TABLE IF EXISTS products CASCADE;"
      echo "Database reset successfully."
    fi
  fi
}

# Run migrations
run_migrations() {
  echo "Running migrations..."
  
  # Look for all migration files in the migrations directory and run them in order
  for migration in $(ls -1 migrations/*.up.sql | sort); do
    echo "Running migration: $migration"
    # Run the migration
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME < $migration
    if [ $? -eq 0 ]; then
      echo "Completed migration: $migration"
    else
      echo "Error running migration: $migration"
      exit 1
    fi
  done
  
  echo "All migrations completed successfully!"
}

# Verify migration success
verify_migrations() {
  echo "Verifying migrations..."
  
  # Check if products table exists and has the right number of rows
  product_count=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM products;")
  product_count=$(echo $product_count | xargs)  # Trim whitespace
  
  if [ "$product_count" -eq "15" ]; then
    echo "Verification successful! Found 15 products."
  else
    echo "Verification warning: Expected 15 products, but found $product_count."
  fi

  # Check if reviews table exists
  review_count=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM reviews;")
  review_count=$(echo $review_count | xargs)  # Trim whitespace
  
  echo "Found $review_count reviews."
  
  echo "Database setup complete!"
}

# Main script execution
usage
check_commands
get_credentials
test_connection
ensure_database
run_migrations
verify_migrations

echo "===== AWS RDS Database Deployment Completed Successfully! ====="
echo "Your database is now ready to use with your application."
echo ""
echo "Connection string: postgresql://$DB_USER:****@$DB_HOST:$DB_PORT/$DB_NAME" 