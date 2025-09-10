# modules/rds/outputs.tf (UPDATED FOR AWS-MANAGED SECRETS - VALIDATED ✅)
output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "master_user_secret_arn" {
  description = "ARN of the master user secret managed by AWS RDS"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "kms_key_id" {
  description = "KMS key ID for the RDS secret"
  value       = aws_kms_key.rds_secret.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN for the RDS secret"
  value       = aws_kms_key.rds_secret.arn
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}