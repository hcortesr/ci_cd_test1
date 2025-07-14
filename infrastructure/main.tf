terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "apache_sec_group" {
  name        = "SG for the apache server"
  description = "This is just the sg for the apache server"
}

resource "aws_vpc_security_group_ingress_rule" "rule_ssh" {
  security_group_id = aws_security_group.apache_sec_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "rule_http" {
  security_group_id = aws_security_group.apache_sec_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "rule_all_traffic" {
  security_group_id = aws_security_group.apache_sec_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "apache_server" {
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.apache_sec_group.id]

  user_data = file("${path.module}/data.sh")

  tags = {
    Name = "apache-test-tf"
  }
}