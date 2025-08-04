provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.tags
  }
}

provider "consul" {
  address    = "consul.core-services.leaseplan.systems"
  datacenter = "euw1"
  scheme     = "https"
}

provider "vault" {
}

provider "aws" {
  alias  = "route53-zone-internal"
  region = data.aws_region.current.name
  assume_role {
    role_arn = var.context == "pipeline" ? data.consul_keys.zone_internal.var.pipeline : data.consul_keys.zone_internal.var.userland
  }
}

provider "datadog" {
  api_url = "https://api.datadoghq.eu/"
}
