locals {
  project     = "lpfat"
  entity      = "LPBR"
  environment = "production"
  workload    = "0072-wkl-lpbr-apps"

  # TODO: values to be replaced by Workload team
  application = "to-be-filled-in"
  wbs_code    = "to-be-filled-in"

  tags = {
    "leaseplan:application" = local.application
    "leaseplan:entity"      = local.entity
    "leaseplan:environment" = local.environment
    "leaseplan:workload"    = local.workload
    "leaseplan:project"     = local.project
    "leaseplan:wbs"         = local.wbs_code
  }
}
