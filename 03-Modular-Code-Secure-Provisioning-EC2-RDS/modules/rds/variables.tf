# modules/rds/variables.tf (UPDATED - NO PASSWORD VARIABLE - VALIDATED ✅)
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for RDS instance"
  type        = list(string)
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
}