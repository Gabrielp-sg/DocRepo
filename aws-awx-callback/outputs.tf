output "user_data" {
  description = "Rendered user_data in non Base64 cleartext"
  value = templatefile("${path.module}/templates/awx-callback-${var.os_type}.tpl", {
    secret_id   = "${var.workload_number}-${var.workload_type}-${var.environment_id}-automation-user",
    template_id = var.template_id,
    awx_url     = local.awx_url,
    extra_vars  = replace(replace(jsonencode(var.extra_vars), "{", ""), "}", "")
    region      = var.region
  })
}

output "user_data_base64" {
  description = "Rendered user_data Base64 encoded"
  value = base64encode(templatefile("${path.module}/templates/awx-callback-${var.os_type}.tpl", {
    secret_id   = "${var.workload_number}-${var.workload_type}-${var.environment_id}-automation-user",
    template_id = var.template_id,
    awx_url     = local.awx_url,
    extra_vars  = replace(replace(jsonencode(var.extra_vars), "{", ""), "}", ""),
    region      = var.region
  }))
}
