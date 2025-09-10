variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access resources"
  type        = string
}