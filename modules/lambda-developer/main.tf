data "terraform_remote_state" "infrastructure" {
  backend = "local"
  config = {
    path = "./modules/lambda-infrastructure/terraform.tfstate"
  }
}
locals {
  en_vars = {
    Test = "yes"
  }
}
resource "aws_s3_bucket_object" "object" {
  bucket = data.terraform_remote_state.infrastructure.outputs.bucket_name
  key    = "${var.s3_key}/${var.archive_name}"
  source = var.source_archive
  etag = var.archive_md5
}

resource "aws_lambda_function" "lambda_function" {
  depends_on = [aws_s3_bucket_object.object]
  handler = var.function_handler
  function_name = var.function_name
  role          = data.terraform_remote_state.infrastructure.outputs.lambda_role
  source_code_hash = var.archive_sha256
  s3_bucket = data.terraform_remote_state.infrastructure.outputs.bucket_name
  s3_key = "${var.s3_key}/${var.archive_name}"
  runtime = var.runtime
  environment {
    variables = var.en_vars
  }
}

