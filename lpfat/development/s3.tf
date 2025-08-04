module "aws_s3_lpfat" {
  source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-s3-bucket.git?ref=v5.0.0"

  name_prefix   = format("lpfat-%s", module.shared_data.workload.environment_identifier)
  versioning    = true
  force_destroy = true #TODO: This needs to be removed
  tags          = local.tags

  lifecycle_rule = [{
    id     = "expire_old_versions"
    status = "Enabled"
    noncurrent_version_expiration = {
      noncurrent_days = 10
    }
  }]
}
