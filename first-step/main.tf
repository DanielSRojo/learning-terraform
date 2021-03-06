# Select provider
provider "aws" {
  region = var.my-aws-region
}

# Create a virtual private cloud
resource "aws_vpc" "my-first-vpc" {
  cidr_block = var.vpc["range"]

  tags = {
    Name = var.vpc["name"]
  }
}

# Create a subnet inside the vpc
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.my-first-vpc.id
  cidr_block = var.subnet["range"]

  tags = {
    Name = var.subnet["name"]
  }
}

# Create a vpc gateway
resource "aws_internet_gateway" "my-gateway" {
  vpc_id = aws_vpc.my-first-vpc.id
}

# Create a route table
resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-first-vpc.id

  route {
    cidr_block = var.route["allowed"]
    gateway_id = aws_internet_gateway.my-gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.my-gateway.id
  }

  tags = {
    Name = var.route["name"]
  }
}

# Associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.my-route-table.id
}

# Add a security group to allow traffic on ports 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.my-first-vpc.id

  # Allow HTTPS traffic on port 443
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.range["https"] # IP block to be accepted
  }

  # Allow HTTP traffic on port 80
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.range["http"] # IP block to be accepted
  }

  # Allow SSH traffic on port 22
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.range["ssh"] # IP block to be accepted
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Any protocol
    cidr_blocks = var.range["egress"]
  }

  tags = {
    Name = "allow_web"
  }
}

# Create a network interface with an IP in the subnet
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = [var.my-gateway-ip] # An IP in the subnet
  security_groups = [aws_security_group.allow_web.id]
}

# Assign an elastic IP to the previously defined network interface
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = var.my-gateway-ip
  depends_on                = [aws_internet_gateway.my-gateway]
}

# Create Ubuntu server with apache enabled
resource "aws_instance" "web-server-instance" {
  ami               = var.server["ami"]
  instance_type     = var.server["type"]
  availability_zone = var.my-aws-zone
  key_name          = var.server["key_name"]

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo this is a web test > /var/www/html/index.html'
              EOF

  tags = {
    "Name" = var.server["name"]
  }
}
