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

# this data source can be used to get the access to the effective Account ID, User ID, and ARN in which Terraform is authorized 
data "aws_caller_identity" "current" {}

locals {
  root_dir   = "${path.module}/.."
  account_id = data.aws_caller_identity.current.account_id

  default_memory_size = 128
  default_timeout     = 10
  lambda_functions = {
    checkerboard = {
      function_name = "api-lambda"
      memory_size   = local.default_memory_size
      timeout       = local.default_timeout
      build_args    = "--build-arg log_level=${var.log_level}"
    }
  }
}