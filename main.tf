provider "aws" {
  region = var.region
  profile= var.profile
}
data "archive_file" "lambda_zip" {
  type          = "zip"
  source_file   = "index.js"
  output_path   = "archive.zip"
}
//Note:  Secure Strings will be visible in TF state.  So beware!
data "aws_ssm_parameter" "ssm_param" {
  name = "test_param"
}
locals {
  new_param = data.aws_ssm_parameter.ssm_param.value
}
module "lambda" {
  depends_on = [data.archive_file.lambda_zip]
  source = "./modules/lambda-developer"
  function_handler = "index.handler"
  function_name = var.function_name
  s3_key = var.function_name
  archive_name = "archive.zip"
  runtime = "nodejs12.x"
  source_archive = "archive.zip"
  archive_sha256 = filebase64sha256(data.archive_file.lambda_zip.output_path)
  archive_md5 = filemd5(data.archive_file.lambda_zip.output_path)
  en_vars = {"foo":local.new_param,"fiz": "bat"}
}
output "zip_path" {
  value = data.archive_file.lambda_zip.output_path
}