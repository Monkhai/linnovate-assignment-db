# AWS RDS Connection Troubleshooting Guide

## Current Symptoms

- Ping to RDS endpoint is failing (100% packet loss)
- Connection attempts time out
- Unable to verify if the database port is reachable

## Step 1: Check Basic AWS RDS Configuration

### Public Accessibility

1. Log in to AWS Console
2. Navigate to RDS → Databases
3. Select your "test-database" instance
4. Under "Connectivity & security" tab, check "Publicly accessible"
   - This must be set to "Yes" for connections from outside the VPC
   - If set to "No", modify the instance to enable public accessibility

### Security Group Configuration

1. In the same "Connectivity & security" tab, find "VPC security groups"
2. Click on the security group linked to your database
3. Check "Inbound rules"
4. Ensure there's a rule with:
   - Type: PostgreSQL
   - Protocol: TCP
   - Port Range: 5432
   - Source: Your IP address (`192.116.48.64/32`) or `0.0.0.0/0` for testing
   - If missing, add this rule

### Database Instance Status

1. Check if the database status is "Available"
2. If it's in "Maintenance", "Backing up", or another state, wait until it's available

## Step 2: Check Network and VPC Settings

### VPC Configuration

1. In the RDS console, note which VPC your database is in
2. Go to VPC Console → Your VPC
3. Ensure the VPC has an Internet Gateway attached
4. Check the route tables for the subnet(s) where your RDS is deployed
5. Ensure there's a route to `0.0.0.0/0` via the Internet Gateway

### Network ACLs

1. In VPC Console, check Network ACLs for the subnet(s) where RDS is deployed
2. Ensure inbound and outbound rules allow traffic on port 5432

## Step 3: Check AWS Account-Level Restrictions

### Service Control Policies (SCPs)

1. If your AWS account is part of an AWS Organization, there might be SCPs restricting RDS access
2. Check with your AWS Administrator if any such policies might be in place

### IAM Policies

1. Check if your IAM user/role has the necessary permissions to access RDS

## Step 4: Alternative Connection Methods

### Use EC2 as a Jump Host

1. Launch a small EC2 instance in the same VPC as your RDS instance
2. Connect to the EC2 instance via SSH
3. Install PostgreSQL client on EC2: `sudo apt-get install postgresql-client`
4. Try connecting to RDS from EC2:
   ```
   psql -h test-database.cbqgq6yw4uxd.eu-north-1.rds.amazonaws.com -U postgres -d postgres
   ```
5. If successful, this confirms your RDS is working but not publicly accessible

### Use AWS Systems Manager Session Manager

1. If you have Session Manager set up, you can connect to an EC2 instance without opening SSH ports
2. This provides another way to test internal connectivity to your RDS instance

## Step 5: Ask for AWS Support

If all else fails, consider:

1. Consulting AWS Support
2. Asking on AWS Forums
3. Checking AWS Service Health Dashboard for any RDS issues in eu-north-1

## Additional Notes

- The database endpoint might take time to propagate after making changes
- Network ACLs are stateless, so both inbound and outbound rules must be set
- Security groups are stateful, so return traffic is automatically allowed
- Some corporate networks block outbound connections to database ports
