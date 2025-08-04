locals {
  monitor_path  = "${path.module}/monitors/"
  monitor_files = fileset(local.monitor_path, "*.yaml")
  monitor_list  = [for f in local.monitor_files : yamldecode(file("${local.monitor_path}${f}"))]
  monitor_map   = merge(local.monitor_list...)
  monitors      = jsondecode(data.external.yaml_monitors.result.monitors)

  underscore_tags = { for key, value in var.tags : replace(key, ":", "_") => value }
  dd_tags         = [for key, value in local.underscore_tags : "${key}:${value}"]
}

variable "tags" {
  description = "The tags for monitors."
  type        = map(any)
}

variable "url" {
  description = "The url used by the synthetics monitor."
  type        = string
}

variable "environment" {
  description = "The environment in which the resource is deployed."
  type        = string
}
