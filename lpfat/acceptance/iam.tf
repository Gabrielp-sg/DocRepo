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

