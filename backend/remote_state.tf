terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"   # Replace with your S3 bucket name
    key            = "global/infra/terraform.tfstate" # Path inside the bucket
    region         = "us-east-1"                   # AWS region
    dynamodb_table = "terraform-locks"             # DynamoDB table for state locking
    encrypt        = true                          # Enable server-side encryption
  }
}