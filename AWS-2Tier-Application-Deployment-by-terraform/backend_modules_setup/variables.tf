variable "s3_bucket_name" {
  default = "backend-tfstate-bucket-dev"
}

variable "dynamodb_table_name" {
  default = "remote-lock-dev"
}

variable "region" {
  default = "us-east-1"
}
  