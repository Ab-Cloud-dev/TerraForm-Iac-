# main.tf - Root module (SECURE VERSION - NO PASSWORDS IN STATE)
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  allowed_cidr = var.allowed_cidr
}

# RDS Module (AWS manages password)
module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  db_instance_class  = var.db_instance_class
  db_username        = var.db_username
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.rds_security_group_id]
  allocated_storage  = var.allocated_storage
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.security_groups.ec2_security_group_id]
  rds_secret_arn     = module.rds.master_user_secret_arn
  kms_key_id         = module.rds.kms_key_id
}