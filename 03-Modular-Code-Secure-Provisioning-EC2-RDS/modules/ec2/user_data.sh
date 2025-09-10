#!/bin/bash

# Enable logging
exec > >(tee /var/log/user_data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Exit on error
set -e

# Update and install required packages
yum update -y
yum install -y awscli jq mariadb105

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -f awscliv2.zip  # Clean up

# Export variables
export secret_arn="your-secret-arn"
export region="your-region"

# Function to get RDS credentials from Secrets Manager
get_rds_credentials() {
    aws secretsmanager get-secret-value \
        --secret-id "${secret_arn}" \
        --region "${region}" \
        --query SecretString \
        --output text
}

# Create a script to retrieve DB credentials
cat > /home/ec2-user/get-db-creds.sh << 'EOF'
#!/bin/bash
SECRET_ARN="${secret_arn}"
REGION="${region}"

# Get the secret value
SECRET=$(aws secretsmanager get-secret-value --secret-id $SECRET_ARN --region $REGION --query SecretString --output text)

# Parse the JSON to get username and password
DB_USERNAME=$(echo $SECRET | jq -r '.username')
DB_PASSWORD=$(echo $SECRET | jq -r '.password')

echo "Database Username: $DB_USERNAME"
echo "Database Password: $DB_PASSWORD"
EOF

# Set permissions for the script
chmod +x /home/ec2-user/get-db-creds.sh
chown ec2-user:ec2-user /home/ec2-user/get-db-creds.sh