# S3 Bucket: Stores Terraform state files, private access, with versioning enabled.
# DynamoDB Table: Used for state locking, with "PAY_PER_REQUEST" billing and LockID hash key.
# Purpose: Sets up a remote backend for Terraform state management and concurrency control.


provider "aws" {
  region =  var.region
}

resource "aws_s3_bucket" "backend" {
  bucket = var.s3_bucket_name
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name = "Terraform Backend Bucket"
  }
}

resource "aws_dynamodb_table" "backend_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Backend Lock Table"
  }
}
