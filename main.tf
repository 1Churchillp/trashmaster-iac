terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Creating key-pair on AWS using SSH-public key
resource "aws_key_pair" "deployer" {
  key_name   = var.key-name
  public_key = file("~/.local/bin/my-key.pub")
}

# Creating a security group to restrict/allow inbound connectivity
resource "aws_security_group" "network-security-group" {
  name        = var.network-security-group-name
  description = "Allow TLS inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  # Not recommended to add "0.0.0.0/0" instead we need to be more specific with the IP ranges to allow connectivity from.
  tags = {
    Name = "frontend-inbound"
  }
}

resource "aws_instance" "backend" {
  ami           = "ami-0387ac14c76aca343" # trashmaster-backend-01
  instance_type = "t3.medium"
  tags = {
    Name = "TF-build-be-v01-02"
  }
}

resource "aws_instance" "frontend" {
  ami           = var.ubuntu-ami
  instance_type = var.ubuntu-instance-type
  key_name        = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network-security-group.id]
  user_data = <<-EOF
              #!/bin/bash
              set -e
              # prepare frontend location
              mkdir trashmaster
              cd trashmaster
              EOF
              

  tags = {
    Name = "TF-build-fe-v01-02"
  }
}

resource "aws_s3_bucket" "ami_bucket" {
  bucket = "trashmaster-ami-backup-2026" # Must be globally unique

  tags = {
    Name        = "Ami Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.ami_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
