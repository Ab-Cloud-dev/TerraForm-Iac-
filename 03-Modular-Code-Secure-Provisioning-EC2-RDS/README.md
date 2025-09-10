# Secure AWS Infrastructure with Terraform

This Terraform configuration creates a secure AWS infrastructure with:

- VPC with public/private subnets
- EC2 instance in public subnet
- RDS MySQL database in private subnet
- **AWS-managed secrets (NO passwords in Terraform state)**
- KMS encryption for secrets
- Proper security groups and IAM roles

## 🔐 Security Features

✅ **No passwords in Terraform state file**  
✅ **AWS manages RDS passwords automatically**  
✅ **KMS encryption for secrets**  
✅ **Encrypted EBS volumes**  
✅ **Proper security group isolation**  
✅ **IAM roles with minimal permissions*


## 📁 Directory Structure

```
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars (create from terraform.tfvars.example)
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security_groups/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── user_data.sh
    └── rds/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## 🚀 Deployment Instructions

### 1. Prerequisites
```bash
# Install Terraform
# Configure AWS credentials
aws configure

# Verify credentials
aws sts get-caller-identity
```

### 2. Get Your IP Address
```bash
curl ifconfig.me
# Use this IP in terraform.tfvars as: allowed_cidr = "YOUR_IP/32"
```

### 3. Configure Variables
```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# IMPORTANT: Set your IP address for allowed_cidr
```

### 4. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 5. Access Database Credentials
```bash
# SSH to EC2 instance (if key_name is configured)
ssh ec2-user@<public-ip>

# Get database credentials
./get-db-creds.sh

# Test database connection
./test-db-connection.sh
```

## 🔧 Configuration Options

### Security Levels

**Development (Less Secure):**
```hcl
allowed_cidr = "0.0.0.0/0"  # Allows access from anywhere
```

**Production (Secure):**
```hcl
allowed_cidr = "10.0.0.0/8"     # Internal network only
# or
allowed_cidr = "1.2.3.4/32"     # Your specific IP only
```

### RDS Options

The RDS instance is configured with:
- AWS-managed password (secure)
- KMS encryption
- Automated backups (7 days)
- Performance Insights enabled
- Enhanced monitoring

## 📊 Outputs

After deployment, you'll get:
- VPC ID
- EC2 instance ID and public IP
- RDS endpoint
- AWS Secrets Manager ARN
- Command to retrieve credentials

## 🗑️ Cleanup

```bash
# Destroy all resources
terraform destroy
```

## 🔍 Security Best Practices

1. **Never use 0.0.0.0/0** for allowed_cidr in production
2. **Use specific IP addresses** or VPN endpoints
3. **Enable MFA** on AWS accounts
4. **Regularly rotate** database passwords via AWS Secrets Manager
5. **Monitor access** using CloudTrail and CloudWatch
6. **Keep Terraform state secure** (use S3 backend with encryption)

## 💡 Troubleshooting

### Common Issues:

**1. Secret retrieval fails:**
```bash
# Check IAM permissions
aws sts get-caller-identity
aws iam get-role --role-name your-project-ec2-role
```

**2. Database connection fails:**
```bash
# Check security groups
# Verify RDS is in private subnet
# Test network connectivity
```

**3. Terraform validation errors:**
```bash
# Check syntax
terraform validate

# Check formatting

### 1. **Retrieve RDS Credentials and Store Them in Environment Variables**

Modify your user_data.sh script to export the RDS credentials as environment variables dynamically. These variables will be available to any process running on the EC2 instance.

#### Updated user_data.sh Script:
```
### Explanation on the user_data.sh in getting the credentails from the Secret Manager and setting the credentails as Environment variables.


```
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

# **Retrieve RDS credentials from AWS Secrets Manager**
SECRET=$(aws secretsmanager get-secret-value \
    --secret-id "${secret_arn}" \
    --region "${region}" \
    --query SecretString \
    --output text)

# Parse the JSON to extract username and password
DB_USERNAME=$(echo $SECRET | jq -r '.username')
DB_PASSWORD=$(echo $SECRET | jq -r '.password')

# Export credentials as environment variables
echo "Exporting RDS credentials as environment variables..."
echo "export DB_USERNAME=${DB_USERNAME}" >> /etc/profile.d/rds_env.sh
echo "export DB_PASSWORD=${DB_PASSWORD}" >> /etc/profile.d/rds_env.sh
echo "export DB_HOST=your-rds-endpoint" >> /etc/profile.d/rds_env.sh
echo "export DB_NAME=your-database-name" >> /etc/profile.d/rds_env.sh

# Set permissions for the environment file
chmod 600 /etc/profile.d/rds_env.sh
```


---

### 2. **How It Works**

1. **Retrieve Credentials**:
   
   - The script fetches the RDS credentials (`username` and `password`) from AWS Secrets Manager using the AWS CLI.
   - The credentials are parsed using `jq`.

2. **Store in Environment Variables**:
   
   - The credentials are written to `/etc/profile.d/rds_env.sh`, which is sourced automatically for all users when they log in.
   - The `DB_USERNAME`, `DB_PASSWORD`, `DB_HOST`, and `DB_NAME` environment variables are set.

3. **Secure the Environment File**:
   
   - The file `/etc/profile.d/rds_env.sh` is given restrictive permissions (`chmod 600`) to ensure only root and privileged users can access it.
   
   ```
   mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD $DB_NAME
   ```

---

### 3. **Accessing the Environment Variables**

Once the script runs, the environment variables will be available to any process or script running on the EC2 instance. For example:

#### Example: Connect to RDS Using the Environment Variables

- 
- 
- 
- 

#### Example: Use in a Script

- 
- 
- 
- 

---

### 4. **Advantages of This Approach**

- **No Hardcoding**: Credentials are not hardcoded in scripts or code.
- **Secure**: The credentials are stored in memory as environment variables and are not exposed in plain text files.
- **Reusable**: Any application or script running on the EC2 instance can access the credentials without needing to fetch them again.

---

### 5. **Best Practices**

- **Use IAM Roles**: Ensure the EC2 instance has an IAM role with permissions to access AWS Secrets Manager.
- **Restrict Access**: Limit access to the `/etc/profile.d/rds_env.sh` file to only privileged users.
- **Rotate Secrets**: Regularly rotate the RDS credentials in AWS Secrets Manager and ensure the environment variables are updated dynamically.

---

Let me know if you need further clarification or help implementing this!
