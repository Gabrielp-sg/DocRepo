module "aws_security_load_balancer" {
  source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-security-group.git?ref=v5.0.0"

  name        = format("sgp-%s-%s-alb-lpfat-app", local.workload_number, local.environment_identifier)
  description = "LPFat SG"
  vpc_id      = module.shared_data.vpc.vpc.id
  ingress_rules = [
    {
      description = "Allow inbound HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      description = "Allow inbound HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    },
  ]
  egress_rules = [
    {
      description              = "Allow outbound HTTP from ASG"
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      source_security_group_id = module.aws_launch_template_lpfat.aws_security_group.id
    },
    {
      description              = "Allow outbound HTTP from ASG"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = module.aws_launch_template_lpfat.aws_security_group.id
    },
    {
      description = "Allow outbound SFTP from ASG instance"
      from_port   = 57222
      to_port     = 57222
      protocol    = "tcp"
      cidr_blocks = ["187.72.125.120/32"]
    },
  ]
  tags = local.tags
}
