# Basic Configuration
project_name = "my-secure-app"
aws_region   = "us-east-1"

# Network Configuration  
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Security Configuration (IMPORTANT: Change this!)
# Get your IP: curl ifconfig.me
allowed_cidr = "0.0.0.0/0" # ⚠️ CHANGE THIS TO YOUR IP: "1.2.3.4/32"

# EC2 Configuration
ami_id        = "ami-0a232144cf20a27a5" # Amazon Linux 2023
instance_type = "t3.micro"
key_name      = "" # Add your key pair name if you want SSH access

# RDS Configuration
db_instance_class = "db.t3.micro"
db_username       = "admin"
allocated_storage = 20