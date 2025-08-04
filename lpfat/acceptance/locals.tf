locals {
  project           = "lpfat"
  entity            = "LPBR"
  environment       = "acceptance"
  workload          = "0072-wkl-lpbr-apps"
  environment_short = "acc"
  datadog           = "true"
  backup            = "non-prod"
  application       = "brazil-loc-apps"
  wbs_code          = "LPBR-LOC-APPS"
  team              = "lpbr_it"
  service           = "brazil-loc-apps-lpfat"
  version           = "1.0.0"


  account_id           = data.aws_caller_identity.current.account_id
  elb_logs_bucket_name = "plt-elb-logs-${local.account_id}-${var.aws_region}"

  #Locals for ASG
  instance_type_alb = "t3a.medium"
  min_size          = 1
  max_size          = 1
  desired_capacity  = 1

  workload_index         = substr(local.workload, 0, 4)
  workload_number        = substr(local.workload, 0, 4)
  environment_identifier = substr(local.environment, 0, 1)
  k8s_namespace          = "0072"

  #Locals for Windows
  instance_type_win = "t3a.medium"
  iam_role_name     = format("role-%s-%s-ec2-win-lpfat", local.workload_number, local.environment_identifier)
  ec2_sg_name       = format("sgp-%s-%s-base-lpfat", local.workload_number, local.environment_identifier)

  region                       = data.aws_region.current.name
  firehose_stream_for_waf_logs = format("aws-waf-logs-delivery-stream-%s", local.region)

  domains_name              = ["lpfat.acc.lpbr.internal.leaseplan.systems"]
  certificate_authority_arn = "arn:aws:acm-pca:sa-east-1:628335837393:certificate-authority/76ebcb5a-0629-4daf-83d7-64e5bc57f510"

  tags = {
    "leaseplan:application"   = local.application
    "leaseplan:entity"        = local.entity
    "leaseplan:environment"   = local.environment
    "leaseplan:workload"      = local.workload
    "leaseplan:project"       = local.project
    "leaseplan:wbs"           = local.wbs_code
    "leaseplan:datadog"       = local.datadog
    "leaseplan:team"          = local.team
    "leaseplan:backup:tier"   = local.backup
    "leaseplan:k8s_namespace" = local.k8s_namespace
    "env"                     = local.environment_short
    "service"                 = local.service
    "version"                 = local.version
  }

  tags_lt = merge(local.tags, {
    "leaseplan:os:type"      = "linux"
    "leaseplan:os:version"   = "amazon-linuxv2023"
    "leaseplan:patch:reboot" = "false"
    "leaseplan:patch:zone"   = "green"
    "Name"                   = format("ec2-%s-%s-sae1-lpfat-lp", local.workload_number, local.environment_identifier)
  })

  tags_ec2_win = merge(local.tags, {
    "leaseplan:os:type"      = "windows"
    "leaseplan:os:version"   = "windows2022"
    "leaseplan:patch:reboot" = "true"
    "leaseplan:patch:zone"   = "green"
  })
}


