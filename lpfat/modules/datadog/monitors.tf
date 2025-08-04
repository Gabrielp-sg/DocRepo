module "baseline_monitors" {
  source   = "git::ssh://git@gitlab.core-services.leaseplan.systems/shared/terraform_modules/datadog/datadog-monitor.git?ref=dev"
  for_each = local.monitors

  monitor_name      = each.value.name
  monitor_type      = lookup(each.value, "type", "metric alert")
  priority          = each.value.priority
  query             = each.value.query
  message           = each.value.message
  tags              = var.tags
  optional_settings = lookup(each.value, "optional_settings", {})
}
