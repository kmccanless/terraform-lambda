output "bucket_name" {
  value = aws_s3_bucket.lambda_bucket.id
}
output "asset_bucket_name" {
  value = aws_s3_bucket.lambda_asset_bucket.id
}
output "lambda_role" {
  value = aws_iam_role.lambda_iam_role.arn
}
output "developer_access_key" {
  value = aws_iam_access_key.lambda-developers-key.id
}
output "developer_access_secret" {
  value = aws_iam_access_key.lambda-developers-key.secret
}
