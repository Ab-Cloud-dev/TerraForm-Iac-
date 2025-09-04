resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "my-generated-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "my-generated-key.pem"
  file_permission = "0400"
}

resource "aws_instance" "web_server_1" {
  ami                    = "ami-0360c520857e3138f"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = aws_key_pair.generated_key.key_name
  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "web_server_2" {
  ami                    = "ami-0360c520857e3138f"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = aws_key_pair.generated_key.key_name
  tags = {
    Name = "web-server-2"
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = "ami-0360c520857e3138f"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = aws_key_pair.generated_key.key_name
  tags = {
    Name = "bastion-host"
  }
}