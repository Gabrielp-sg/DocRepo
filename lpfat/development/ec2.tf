module "awx_win_provision" {

  source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-awx-callback.git?ref=v1.3.0"

  template_id     = "3870"
  os_type         = "windows"
  region          = var.aws_region
  workload_number = local.workload_index
  environment_id  = local.environment_identifier

  #   extra_vars = {
  #     "tasks" = ["install_lpfat_tools"]
  #   }
}

module "ec2_lpfat_windows" {
  source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-instance.git?ref=v5.0.0"

  name                           = format("ec2-%s-%s-sae1-lpfatwin-lp", local.workload_number, local.environment_identifier)
  ami                            = module.shared_data.ami_id.windows.2022.id
  subnet_id                      = module.shared_data.vpc.private_subnets_map["a"].id
  instance_type                  = "t3.small"
  enable_ffm_base_security_group = false
  user_data                      = module.awx_win_provision.user_data

  tags = local.tags_ec2_win

  root_block_device = {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 100
    volume_type           = "gp3"
  }

  iam_role = {
    name = local.iam_role_name
    policy_arns = [
      aws_iam_policy.policy_lpfat_access_s3.arn,
      "arn:aws:iam::${local.account_id}:policy/plt-instance-profile-policy",
      aws_iam_policy.awx_secrets_read.arn
    ]
  }

  instance_security_group = {
    name = local.ec2_sg_name
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
        description = "Allow access from all LP network."
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
        description = "Allow access to RDP"
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "all"
        cidr_blocks = ["10.0.0.0/8"]
        description = "Allow access to all LP network."
      }
    ]
  }
}
