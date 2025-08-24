output "kke_vpc_name" {
  description = "The name of the VPC"
  value       = aws_vpc.datacenter_vpc.tags["Name"]
}

output "kke_subnet_name" {
  description = "The name of the Subnet"
  value       = aws_subnet.datacenter_subnet.tags["Name"]
}
