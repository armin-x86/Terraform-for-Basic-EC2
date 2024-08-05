# challenge/terraform
# versions.tf

terraform {
  required_version = "~>1.3.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
    }
  }
}
