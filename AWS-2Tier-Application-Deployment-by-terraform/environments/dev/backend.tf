terraform {
  backend "s3" {
    bucket = "backend-tfstate-bucket-dev"
    key    = "backend-tfstate-bucket-dev/AWS-2Tier.tfstate"
    region = "us-east-1"
    dynamodb_table = "remote-lock-dev"
  }
}


