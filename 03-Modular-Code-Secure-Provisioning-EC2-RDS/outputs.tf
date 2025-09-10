# outputs.tf - Root module outputs (SECURE VERSION)
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
}

output "rds_secret_arn" {
  description = "ARN of the AWS-managed RDS master user secret"
  value       = module.rds.master_user_secret_arn
}

output "kms_key_id" {
  description = "KMS key ID for RDS secret encryption"
  value       = module.rds.kms_key_id
}

output "get_credentials_command" {
  description = "Command to retrieve database credentials"
  value       = "aws secretsmanager get-secret-value --secret-id ${module.rds.master_user_secret_arn} --region ${var.aws_region} --query SecretString --output text | jq -r '.'"
}