data "aws_iam_policy_document" "policy_lpfat_access_s3" {
  statement {
    sid    = "ObjectAccess"
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObjectVersion",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::lpfat-*/*",
      "arn:aws:s3:::lpfat-*",
    ]
  }
}

resource "aws_iam_policy" "policy_lpfat_access_s3" {
  name        = format("policy-0072-%s-lpfat-access-s3", module.shared_data.workload.environment_identifier)
  path        = "/"
  description = "Allow LPFAT app to access S3 bucket."
  policy      = data.aws_iam_policy_document.policy_lpfat_access_s3.json

  tags = local.tags
}

# resource "aws_iam_policy" "scheduler_lpfat_lambda_policy" {
#   name = format("policy-%s-%s-scheduler-lpfat-lambda", local.workload_number, local.environment_identifier)

#   policy = jsonencode(
#     {
#       "Version" : "2012-10-17",
#       "Statement" : [
#         {
#           "Sid" : "AllowLambda",
#           "Effect" : "Allow",
#           "Action" : [
#             "lambda:InvokeFunction",
#           ],
#           "Resource" : module.aws_lambda_fetch_from_sftp.lambda_function_arn
#         }
#       ]
#     }
#   )
#   tags = local.tags
# }

# resource "aws_iam_role" "scheduler-lpfat-lambda-role" {
#   name                 = format("role-%s-%s-scheduler-lpfat-lambda", local.workload_number, local.environment_identifier)
#   managed_policy_arns  = [aws_iam_policy.scheduler_lpfat_lambda_policy.arn]
#   permissions_boundary = format("arn:aws:iam::%s:policy/workload-boundary", local.account_id)

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "scheduler.amazonaws.com"
#         }
#       },
#     ]
#   })
#   tags = local.tags
# }