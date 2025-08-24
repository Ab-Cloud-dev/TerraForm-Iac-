# Create VPC
resource "aws_vpc" "datacenter_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.KKE_VPC_NAME
  }
}

# Create Subnet with explicit dependency on VPC
resource "aws_subnet" "datacenter_subnet" {
  vpc_id            = aws_vpc.datacenter_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Adjust as needed
  depends_on        = [aws_vpc.datacenter_vpc]

  tags = {
    Name = var.KKE_SUBNET_NAME
  }
}
