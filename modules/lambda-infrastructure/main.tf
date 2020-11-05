provider "aws" {
  region = var.region
  profile= var.profile
}

resource "aws_s3_bucket" "lambda_bucket" {
  force_destroy = true
  bucket = var.s3_bucket
  versioning {
    enabled = true
  }
  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }
  acl = "private"
}
resource "aws_s3_bucket" "lambda_asset_bucket" {
  bucket = var.s3_asset_bucket
  acl = "private"
}
resource "aws_iam_user" "lambda-developer" {
  name = "lambda-developer"
  path = "/"
}

resource "aws_iam_group" "lambda-developers" {
  name = "lambda-developers"
  path = "/"
}
resource "aws_iam_access_key" "lambda-developers-key" {
  user = aws_iam_user.lambda-developer.name
}
resource "aws_iam_group_membership" "lambda-developers-add" {
  name = "lambda-developers"

  users = [
    aws_iam_user.lambda-developer.name
  ]

  group = aws_iam_group.lambda-developers.name
}
resource "aws_iam_group_policy_attachment" "lambda-developer-attach" {
  group      = aws_iam_group.lambda-developers.name
  policy_arn = aws_iam_policy.Lambda-developer-rights.arn
}

resource "aws_iam_policy" "Lambda-developer-rights" {
  name   = "LambdaAccess"
  policy = data.aws_iam_policy_document.lambda_developer_policy_document.json
}

data "aws_iam_policy_document" "lambda_developer_policy_document" {
  statement {
    sid = "PermissionToCreateFunction"
    actions = [
      "lambda:*"
    ]
    resources = ["*"]
  }
  statement {
    sid ="PassRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [aws_iam_role.lambda_iam_role.arn]
  }
  statement {
    actions = [
    "ssm:DescribeParameters"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
    "ssm:GetParameter"
    ]
    resources = ["arn:aws:ssm:us-east-2:063329109067:parameter/test_param"]
  }
 statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket}",
      "arn:aws:s3:::${var.s3_bucket}/*",
      "arn:aws:s3:::${var.s3_asset_bucket}",
      "arn:aws:s3:::${var.s3_asset_bucket}/*"
    ]
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_lambda_execution.arn
}
resource "aws_iam_policy" "lambda_lambda_execution" {
  name = "lambda__execution"
  policy = data.aws_iam_policy_document.lambda_policy_data.json
}

data "aws_iam_policy_document" "lambda_policy_data" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket}",
      "arn:aws:s3:::${var.s3_bucket}/*",
      "arn:aws:s3:::${var.s3_asset_bucket}",
      "arn:aws:s3:::${var.s3_asset_bucket}/*"
    ]
  }
}


