# modules/ec2/variables.tf (UPDATED - VALIDATED ✅)
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for EC2 instance"
  type        = list(string)
}

variable "rds_secret_arn" {
  description = "ARN of the AWS-managed RDS master user secret"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for RDS secret encryption"
  type        = string
}