resource "aws_vpc" "learning_platform_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "LPVpc"
  }
}

resource "aws_internet_gateway" "learning_platform_gw" {
  vpc_id = aws_vpc.learning_platform_vpc.id

  tags = {
    Name = "LPGateway"
  }
}

resource "aws_subnet" "learning_platform_public_subnet" {
  vpc_id     = aws_vpc.learning_platform_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "LPPublicSubnet"
  }
}

resource "aws_subnet" "learning_platform_private_subnet" {
  vpc_id     = aws_vpc.learning_platform_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "LPPrivateSubnet"
  }
}

resource "aws_route_table" "learning_platform_route_table" {
  vpc_id = aws_vpc.learning_platform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.learning_platform_gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.learning_platform_gw.id
  }

  tags = {
    Name = "LPRouteTable"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.learning_platform_public_subnet.id
  route_table_id = aws_route_table.learning_platform_route_table.id
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.learning_platform_private_subnet.id
  route_table_id = aws_route_table.learning_platform_route_table.id
}

# Security Group

resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow SSH/HTTP/HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.learning_platform_vpc.id

  tags = {
    Name = "allow_web_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tomcat" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all ports
}


# Network Interface

# TODO: API Gateway in public subnet, EC2 instance in private subnet
resource "aws_network_interface" "frontend_nic" {
  subnet_id       = aws_subnet.learning_platform_public_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web_traffic.id]
}

resource "aws_network_interface" "backend_nic" {
  subnet_id       = aws_subnet.learning_platform_private_subnet.id
  private_ips     = ["10.0.2.50"]
  security_groups = [aws_security_group.allow_web_traffic.id]
}

# Assign an elastic IP to NIC

resource "aws_eip" "frontend_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.frontend_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.learning_platform_gw, aws_network_interface.frontend_nic]
}

resource "aws_eip" "backend_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.backend_nic.id
  associate_with_private_ip = "10.0.2.50"
  depends_on = [aws_internet_gateway.learning_platform_gw, aws_network_interface.backend_nic, var.ec2_instance_id]
}