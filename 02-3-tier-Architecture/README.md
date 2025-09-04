# AWS Three-Tier Web Application Infrastructure

A complete Infrastructure as Code (IaC) implementation using Terraform to deploy a scalable, secure three-tier web application on AWS with load balancing, database connectivity, and bastion host access.

## 🏗️ Architecture Overview

This project demonstrates the deployment of a production-ready web application infrastructure following AWS best practices for security, scalability, and high availability.

### Architecture Components

```
Internet Gateway
       |
   Public Subnet (ALB + Bastion Host)
       |
   Application Load Balancer
       |
   Private Subnets (Web Servers)
       |
   Database Subnets (RDS MySQL)
```

## 🚀 Features

- **High Availability**: Multi-AZ deployment across two availability zones
- **Security**: Private subnets for web servers and database with NAT Gateway for outbound traffic
- **Load Balancing**: Application Load Balancer for traffic distribution
- **Database**: RDS MySQL instance with proper subnet groups and security groups
- **Secure Access**: Bastion host for SSH access to private instances
- **Infrastructure as Code**: Complete Terraform configuration for reproducible deployments

## 🛠️ Technology Stack

- **Infrastructure**: AWS (VPC, EC2, RDS, ALB, NAT Gateway)
- **IaC Tool**: Terraform
- **Operating System**: Ubuntu
- **Web Server**: Apache HTTP Server
- **Backend**: PHP 5.6
- **Database**: MySQL (RDS)
- **Monitoring**: CloudWatch (implicit)

## 📋 Prerequisites

Before deploying this infrastructure, ensure you have:

- AWS CLI configured with appropriate credentials
- Terraform installed (version >= 0.14)
- SSH key pair created in AWS EC2
- Basic understanding of AWS networking concepts

## 🏢 Infrastructure Components

### Network Layer
- **VPC**: Custom Virtual Private Cloud with CIDR block
- **Public Subnets**: 1 subnet for ALB and Bastion Host
- **Private Subnets**: 2 subnets for web servers across different AZs
- **Database Subnets**: 2 subnets for RDS across different AZs
- **Internet Gateway**: Provides internet access to public subnet
- **NAT Gateway**: Enables outbound internet access for private subnets

### Compute Layer
- **Application Load Balancer**: Distributes traffic across web servers
- **Web Servers**: 2 EC2 instances (web_server_1, web_server_2) running Ubuntu
- **Bastion Host**: EC2 instance for secure SSH access to private instances

### Database Layer
- **RDS MySQL Instance**: Managed database service in private subnets
- **DB Subnet Group**: Spans multiple AZs for high availability
- **Security Groups**: Restricts database access to web servers only

### Security Groups Configuration

#### ALB Security Group
- **Inbound**: HTTP (80), HTTPS (443) from 0.0.0.0/0
- **Outbound**: All traffic to web servers

#### Web Server Security Group
- **Inbound**: HTTP (80) from ALB security group, SSH (22) from Bastion
- **Outbound**: HTTPS (443) for updates, MySQL (3306) to database

#### Bastion Host Security Group
- **Inbound**: SSH (22) from your IP address
- **Outbound**: SSH (22) to web servers

#### Database Security Group
- **Inbound**: MySQL (3306) from web server security group only
- **Outbound**: None required

## 🚀 Deployment Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd aws-three-tier-infrastructure
```

### 2. Configure Terraform Variables
```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the variables file with your specific values
nano terraform.tfvars
```

### 3. Initialize and Plan
```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan
```

### 4. Deploy Infrastructure
```bash
# Apply the configuration
terraform apply

# Confirm with 'yes' when prompted
```

### 5. Verify Deployment
After successful deployment, you'll receive outputs including:
- ALB DNS name
- Bastion host public IP
- Web server private IPs

## 💻 Application Setup

### Automated Installation
The Terraform configuration includes user data scripts that automatically:

1. **Update System Packages**
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   ```

2. **Install Web Server Stack**
   ```bash
   sudo apt-get install apache2 php5.6 php5.6-mysql -y
   ```

3. **Configure Apache**
   ```bash
   sudo systemctl enable apache2
   sudo systemctl start apache2
   ```

4. **Deploy Application Code**
   - Custom `index.php` file with database connectivity
   - Form for data entry and display
   - Connection testing functionality

### Application Features
- **Database Connectivity**: Establishes connection to RDS MySQL instance
- **Data Entry Form**: HTML form for inserting data into database
- **Data Display**: Shows stored data from database
- **Connection Status**: Displays database connection health
- **Server Information**: Shows which web server is responding

## 🔒 Security Implementation

### Network Security
- Web servers in private subnets (no direct internet access)
- Database in isolated subnets with restricted access
- NAT Gateway for secure outbound connectivity
- Bastion host as single point of entry

### Access Control
- Security groups with principle of least privilege
- SSH access only through bastion host
- Database access restricted to web servers only
- Load balancer health checks configured

### Best Practices Implemented
- Multi-AZ deployment for high availability
- Separate subnets for different tiers
- Encrypted database storage (optional)
- CloudWatch monitoring enabled
- Auto-scaling groups (can be extended)

## 📊 Monitoring and Maintenance

### Health Checks
- ALB health checks on web servers
- RDS monitoring and alerting
- EC2 instance monitoring

### Backup Strategy
- RDS automated backups enabled
- Point-in-time recovery available
- Cross-region backup (can be configured)

## 🧪 Testing the Deployment

### 1. Access the Application
```bash
# Get the ALB DNS name from Terraform output
terraform output alb_dns_name

# Access the application in browser
http://<alb-dns-name>
```

### 2. Test Database Connectivity
- Fill out the form on the web page
- Submit data to verify database insertion
- Refresh to see stored data displayed

### 3. Test Load Balancing
- Multiple refreshes should show different server responses
- Both web_server_1 and web_server_2 should handle requests

### 4. SSH Access Testing
```bash
# Connect to bastion host
ssh -i <key-pair>.pem ubuntu@<bastion-public-ip>

# From bastion, connect to web servers
ssh ubuntu@<web-server-private-ip>
```

## 💰 Cost Optimization

### Current Resources Cost Estimation
- **EC2 Instances**: 3 x t3.micro (~$25/month)
- **RDS Instance**: db.t3.micro (~$20/month)
- **ALB**: ~$22/month
- **NAT Gateway**: ~$45/month
- **Total Estimated**: ~$112/month

### Optimization Strategies
- Use spot instances for non-production environments
- Schedule instances to run only during business hours
- Implement auto-scaling based on demand
- Use reserved instances for predictable workloads

## 🔄 CI/CD Integration

This infrastructure can be extended with:
- **GitHub Actions**: Automated Terraform deployments
- **AWS CodePipeline**: Application deployment pipeline
- **Docker**: Containerized application deployment
- **Kubernetes**: Container orchestration with EKS

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. Terraform Apply Fails
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify region and permissions
terraform plan -detailed-exitcode
```

#### 2. Web Servers Not Responding
```bash
# Check security group rules
# Verify user data script execution
# Check ALB target group health
```

#### 3. Database Connection Issues
```bash
# Verify RDS security group
# Check database credentials
# Test connectivity from web servers
```

## 🚀 Future Enhancements

### Planned Improvements
- [ ] SSL/TLS certificate implementation
- [ ] Auto Scaling Groups for web servers
- [ ] CloudFront CDN integration
- [ ] Elasticsearch for logging
- [ ] AWS WAF for additional security
- [ ] Multi-region deployment
- [ ] Container orchestration with ECS/EKS
- [ ] Infrastructure monitoring with Prometheus/Grafana

### Advanced Features
- [ ] Blue/Green deployments
- [ ] A/B testing capabilities
- [ ] Disaster recovery implementation
- [ ] Cost optimization automation
- [ ] Security compliance automation

## 📝 Project Structure

```
aws-three-tier-infrastructure/
├── main.tf                 # Main Terraform configuration
├── variables.tf           # Variable definitions
├── outputs.tf             # Output definitions
├── terraform.tfvars       # Variable values (not in repo)
├── modules/
│   ├── vpc/               # VPC module
│   ├── security-groups/   # Security groups module
│   ├── alb/               # Load balancer module
│   ├── ec2/               # EC2 instances module
│   └── rds/               # Database module
├── scripts/
│   └── user-data.sh       # EC2 initialization script
├── docs/
│   ├── architecture.png   # Architecture diagram
│   └── setup-guide.md     # Detailed setup guide
└── README.md              # This file
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com

## 🙏 Acknowledgments

- AWS Documentation and Best Practices
- Terraform Community and Documentation
- Open Source Community for tools and resources

---

⭐ **If you found this project helpful, please give it a star!** ⭐