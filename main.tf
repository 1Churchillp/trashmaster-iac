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

resource "aws_instance" "backend" {
  ami           = "ami-0387ac14c76aca343" # trashmaster-backend-01
  instance_type = "t3.medium"
  tags = {
    Name = "TF-build-be-v01-02"
  }
}

resource "aws_instance" "frontend" {
  ami           = "ami-0ec10929233384c7f" # trashmaster-backend-01
  instance_type = "t3.micro"
  user_data = <<-EOF
              #!/bin/bash
set -e

echo "Updating package lists..."
sudo apt update

echo "Upgrading installed packages..."
# -y assumes 'yes' to all prompts
sudo apt upgrade -y

echo "System update and upgrade complete!"

# install vs code via snap
sudo snap install code --classic

#install nodejs and npm
sudo apt install nodejs npm

# get latest versions
sudo npm install -g n
sudo n lts # Installs the latest Long-Term Support version

# prepare frontend location
mkdir trashmaster
cd trashmaster
              EOF
  tags = {
    Name = "TF-build-fe-v01-01"
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
