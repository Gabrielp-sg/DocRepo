module "shared_data" {
  source = "git::git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-shared-data.git?ref=v5.1.0"

  environment            = local.environment
  workload_number        = local.workload_number
  entity                 = local.entity
  application            = local.application
  wbs                    = local.wbs_code
  project                = local.project
  team                   = local.team
  workload               = local.workload
  service                = local.service
  lookup_sg              = false
  lookup_saprhel8_ami    = false
  lookup_saprhel7_ami    = false
  lookup_saprhel86_ami   = false
  lookup_al2023_ami      = false
  lookup_windows2016_ami = false
}

data "consul_keys" "zone_internal" {
  key {
    path = format("public/plt-network/r53-delegations/0072-wkl-lpbr-apps/%s/r53-lpbr-apps-userland-role", local.environment)
    name = "userland"
  }
  key {
    path = format("public/plt-network/r53-delegations/0072-wkl-lpbr-apps/%s/r53-lpbr-apps-pipeline-role", local.environment)
    name = "pipeline"
  }
}

data "aws_route53_zone" "internal_zone" {
  name         = format("%s.lpbr.internal.leaseplan.systems", local.environment_short)
  private_zone = true
  provider     = aws.route53-zone-internal
}

data "aws_wafv2_rule_group" "compliant" {
  name  = "plt_geo_restriction"
  scope = "REGIONAL"
}

data "aws_iam_policy_document" "awx_secrets" {
  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "awx_secrets_read" {
  name   = format("AWX-SM-read-%s-%s-%s", local.workload_index, local.environment_identifier, local.project)
  policy = data.aws_iam_policy_document.awx_secrets.json

  tags = local.tags
}



