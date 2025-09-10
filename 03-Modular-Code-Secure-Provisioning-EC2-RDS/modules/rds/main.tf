# modules/rds/main.tf (SECURE VERSION - AWS MANAGES PASSWORD - VALIDATED ✅)
# KMS key for encrypting the RDS secret
resource "aws_kms_key" "rds_secret" {
  description             = "KMS key for RDS secret encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.project_name}-rds-secret-key"
  }
}

resource "aws_kms_alias" "rds_secret" {
  name          = "alias/${var.project_name}-rds-secret"
  target_key_id = aws_kms_key.rds_secret.key_id
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-db"
  allocated_storage      = var.allocated_storage
  storage_type          = "gp2"
  storage_encrypted     = true
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = var.db_instance_class
  db_name               = "appdb"
  username              = var.db_username
  
  # AWS manages the password completely - NO PASSWORD IN TERRAFORM STATE!
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.rds_secret.arn
  
  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "07:00-09:00"
  maintenance_window     = "sun:09:00-sun:11:00"
  
  # Performance and monitoring
  performance_insights_enabled = false
  monitoring_interval         = 0
  #monitoring_role_arn        = aws_iam_role.rds_enhanced_monitoring.arn
  
  # Security settings
  skip_final_snapshot = true
  deletion_protection = false
  
  # Enable automatic minor version upgrades
  auto_minor_version_upgrade = true
  
  # Multi-AZ for production (set to false for cost savings in dev)
  multi_az = false

  tags = {
    Name = "${var.project_name}-rds"
  }
}

# IAM role for RDS Enhanced Monitoring
