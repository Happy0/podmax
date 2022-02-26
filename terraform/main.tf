terraform {
    backend "s3" {}
    required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~> 4.2.0"
      }
    }

    required_version = ">= 1.1.6"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

