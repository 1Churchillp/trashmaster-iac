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
