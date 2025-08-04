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
