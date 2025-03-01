# AWS RDS Database Deployment Guide

This guide explains how to deploy your PostgreSQL database to Amazon RDS using the provided script.

## Prerequisites

Before you begin, you'll need:

1. An AWS account with permissions to create and manage RDS instances
2. AWS CLI installed and configured with appropriate credentials
3. PostgreSQL client tools installed on your machine
4. An RDS PostgreSQL instance already created in your AWS account
5. A security group that allows connections from your IP address to the RDS instance on port 5432

If you're using AWS Secrets Manager, you'll also need:

- A secret created in AWS Secrets Manager with your database credentials
- Permissions to access this secret

## Setting Up AWS RDS Instance

If you haven't already created an RDS instance:

1. Log into the AWS Management Console
2. Navigate to RDS service
3. Click "Create database"
4. Select PostgreSQL as the engine
5. Choose appropriate settings for your needs (for testing, a t2.micro or t3.micro instance is sufficient)
6. Create a new security group or use an existing one
7. Make sure to allow inbound traffic on port 5432 from your IP address
8. Note your master username and password

## Using the Deployment Script

Our `deploy_to_aws.sh` script will help you deploy the database schema and seed data to your RDS instance.

### Running the Script

```bash
./deploy_to_aws.sh
```

The script will:

1. Check for required tools (AWS CLI and PostgreSQL client)
2. Ask whether you want to use AWS Secrets Manager or enter credentials manually
3. Connect to your RDS instance and test the connection
4. Create the database if it doesn't exist (or optionally reset it)
5. Run all migrations from the `migrations` directory in order
6. Verify the migrations were successful

### Option 1: Using AWS Secrets Manager

If you choose to use AWS Secrets Manager, you'll need:

- The secret name or ARN
- The AWS region where the secret is stored

Your secret should contain these fields:

```json
{
  "host": "your-rds-endpoint.amazonaws.com",
  "port": "5432",
  "username": "your_master_username",
  "password": "your_password",
  "dbname": "your_database_name"
}
```

### Option 2: Manual Credentials

If you choose to enter credentials manually, you'll need:

- RDS Endpoint (host)
- Port (default is 5432)
- Master username
- Master password
- Database name (default is postgres)

## After Deployment

Once deployment is complete, you can verify that your database is working by connecting to it:

```bash
psql -h your-rds-endpoint.amazonaws.com -U your_username -d your_database
```

Your database should now contain:

- Products table with 15 sample products
- Reviews table with sample reviews

## Troubleshooting

### Connection Issues

If you can't connect to your RDS instance:

1. Check that your security group allows connections from your IP address
2. Verify that your RDS instance is publicly accessible (if attempting to connect from outside AWS)
3. Ensure that your credentials are correct

### Permissions Issues

If you get permission errors:

1. Make sure your database user has sufficient privileges
2. For AWS Secrets Manager, ensure your AWS CLI user has permission to read the secret

### Migration Failures

If migrations fail:

1. Check the error message from the PostgreSQL client
2. Verify that there are no syntax errors in the migration files
3. Ensure that migrations are being applied in the correct order

## Support

If you need additional help, please contact the database team.
