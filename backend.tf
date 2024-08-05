# challenge/terraform
# backend.tf

// Note: Initially, comment out the backend block (local state)
// since Terraform will create the S3 bucket. After the first run,
// switch to S3.


variable "terraform_bucket" {
  type    = string
  default = "challenge-keyrock-rhdguk"
}


// consider attaching policy and define the policy
// object creating o who has access to it
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = var.terraform_bucket

  versioning = {
    status = "Enabled"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}



// 2nd step migrate state to bucket with removing the below comments and running:
// terraform init -migrate-state
// As variables not allowed here so the bucket name
// is hard coded
terraform {
  backend "s3" {
    bucket = "challenge-keyrock-rhdguk"
    key    = "terraform/state"
    region = "us-east-1"
  }
}
