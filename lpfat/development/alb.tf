module "awx_provision" {

  source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-awx-callback.git?ref=v1.3.0"

  template_id     = "4373"
  os_type         = "al2"
  region          = var.aws_region
  workload_number = local.workload_index
  environment_id  = local.environment_identifier

  extra_vars = {
    "tasks" = ["install_lpfat_tools"]
  }
}

module "aws_launch_template_lpfat" {
  source = "git::git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-launch-template.git?ref=v5.0.1"

  name                                 = format("lt-%s-%s-sae1-lpfat-01", local.workload_number, local.environment_identifier)
  disable_api_termination              = false
  update_default_version               = true
  instance_initiated_shutdown_behavior = "terminate"
  ebs_optimized                        = true
  instance_type                        = local.instance_type_alb
  image_id                             = "ami-0263eebdb110c0e1e"
  user_data                            = module.awx_provision.user_data

  iam_role = {
    name = format("role-%s-%s-alb-lpfat", local.workload_number, local.environment_identifier)
    policy_arns = [
      aws_iam_policy.policy_lpfat_access_s3.arn,
      "arn:aws:iam::${local.account_id}:policy/plt-instance-profile-policy",
      aws_iam_policy.awx_secrets_read.arn
    ]
  }

  aws_managed_iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ]

  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  instance_security_group = {
    name = format("sgp-%s-%s-asg-lpfat", local.workload_number, local.environment_identifier)
    ingress_rules = [
      {
        from_port                = 8080
        to_port                  = 8080
        protocol                 = "tcp"
        source_security_group_id = module.aws_security_load_balancer.id
        description              = "Allow inbound HTTP from ALB"
      }
    ]
    egress_rules = [
      {
        from_port   = 57222
        to_port     = 57222
        protocol    = "tcp"
        cidr_blocks = ["187.72.125.121/32"]
      }
    ]
  }

  block_device_mappings = [{
    device_name = "/dev/sda1"
    no_device   = 0
    ebs = {
      volume_type           = "gp3"
      volume_size           = 100
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = module.shared_data.kms_key.arn
  } }]

  tag_specifications = [
    {
      resource_type = "volume"
      tags          = local.tags_lt
    },
    {
      resource_type = "instance"
      tags          = local.tags_lt
    }
  ]
  tags = local.tags
}

module "aws_autoscaling_lpfat" {
  source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-autoscaling-group.git?ref=v5.0.0"

  name             = format("asg-%s-%s-sae1-lpfat-01", local.workload_number, local.environment_identifier)
  min_size         = local.min_size
  max_size         = local.max_size
  desired_capacity = local.desired_capacity

  health_check_type   = "EC2"
  vpc_zone_identifier = module.shared_data.vpc.private_subnet_ids
  target_group_arns   = [module.aws_alb_lpfat.lb_target_groups.tg-p.arn]

  launch_template = {
    id      = module.aws_launch_template_lpfat.launch_template_id
    version = module.aws_launch_template_lpfat.launch_template_latest_version
  }

  depends_on = [module.aws_launch_template_lpfat]

  tags = local.tags

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
  }
}


module "aws_alb_lpfat" {
  source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-alb.git?ref=v5.0.1"

  name            = format("alb-%s-%s-sae1-lpfat-lb01", local.workload_number, local.environment_identifier)
  subnets         = module.shared_data.vpc.private_subnet_ids
  security_groups = [module.aws_security_load_balancer.id]
  certificate_arn = aws_acm_certificate.acm_internal[0].arn
  internal        = true

  targets = [
    {
      name              = "tg-p"
      port              = 8080
      type              = "instance"
      listener_protocol = "HTTP"
      target_protocol   = "HTTP"
      rules             = []

      stickiness = {
        type            = "lb_cookie"
        cookie_duration = "86400" #1day
      }
    }


  ]
  https_listener = {
    type              = "forward"
    port              = 443
    target_group_name = "tg-p"
    ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  }

  tags = local.tags
}
