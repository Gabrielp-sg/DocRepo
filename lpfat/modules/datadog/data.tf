data "external" "yaml_monitors" {
  program = ["python", "${path.module}/process_yaml.py"]

  query = {
    monitors = jsonencode(local.monitor_map)
    tags     = jsonencode(var.tags)
  }
}
