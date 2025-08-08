module "aws_awx_callback_advanced" {
  source          = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-awx-callback.git?ref=tags/TAG_REV"
  os_type         = "al2"
  template_id     = 1111
  workload_type   = "svc"
  workload_number = 9999
  environment_id  = "d"
  extra_vars = {
    "tasks" = ["install_cloudwatch_linux"]
  }
}
