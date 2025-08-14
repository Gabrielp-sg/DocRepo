locals {
  tags = merge(
    var.tags,
    {
      module_project_path = local.module_project_path
      module_version      = local.module_version
    },
  )
}
