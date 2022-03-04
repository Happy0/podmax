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
    apilambda = {
      function_name = "api-lambda"
      memory_size   = local.default_memory_size
      timeout       = local.default_timeout
      build_args    = "--build-arg log_level=${var.log_level}"
    }
  }
}

resource "aws_lambda_function" "api_lambda" {
  function_name = "${var.service_name}-${local.lambda_functions["apilambda"].function_name}-${var.stage}"

  image_uri    = "${aws_ecr_repository.lambda_repository.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type = "Image"

  timeout     = local.lambda_functions["checkerboard"].timeout
  memory_size = local.lambda_functions["checkerboard"].memory_size
  role        = aws_iam_role.lambda_role.arn
}

resource "aws_ecr_repository" "lambda_repository" {
  name = "${var.service_name}-${local.lambda_functions["apilambda"].function_name}-${var.stage}"
}

resource "null_resource" "lambda_ecr_image_builder" {
  triggers = {
    docker_file     = filesha256("${local.root_dir}/Dockerfile")
    cargo_file      = filesha256("${local.root_dir}/Cargo.toml")
    cargo_lock_file = filesha256("${local.root_dir}/Cargo.lock")
    src_dir         = sha256(join("", [for f in fileset("${local.root_dir}/src", "**") : filesha256("${local.root_dir}/src/${f}")]))
  }

  provisioner "local-exec" {
    working_dir = local.root_dir
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
      docker image build -t ${aws_ecr_repository.lambda_repository.repository_url}:latest ${local.lambda_functions["apilambda"].build_args} .
      docker push ${aws_ecr_repository.lambda_repository.repository_url}:latest
    EOT
  }
}

data "aws_ecr_image" "lambda_image" {
  depends_on = [
    null_resource.lambda_ecr_image_builder
  ]

  repository_name = "${var.service_name}-${local.lambda_functions["apilambda"].function_name}-${var.stage}"
  image_tag       = "latest"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.api_lambda.function_name}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.service_name}-${local.lambda_functions["apilambda"].function_name}-iam-role-${var.aws_region}-${var.stage}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "basic_lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}