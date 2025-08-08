module "aws_awx_callback_basic" {
  source          = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-awx-callback.git?ref=tags/TAG_REV"
  os_type         = "windows"
  template_id     = 1111
  workload_number = 9999
  environment_id  = "d"
}
