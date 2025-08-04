# Feel free to bump provider versions, when needed. It is suggested to test in 'development' or 'test' first.
# Check the references changelogs for bugfixes and features.
terraform {
  required_version = "~> 1.9.6"
  required_providers {
    aws = {
      # changelog at https://github.com/hashicorp/terraform-provider-aws/blob/main/CHANGELOG.md
      source  = "hashicorp/aws"
      version = "3.60.0"
    }
    vault = {
      # changelog at https://github.com/hashicorp/terraform-provider-vault/blob/main/CHANGELOG.md
      source  = "hashicorp/vault"
      version = "2.24.0"
    }
    consul = {
      # https://github.com/hashicorp/terraform-provider-consul/blob/master/CHANGELOG.md
      source  = "hashicorp/consul"
      version = "2.13.0"
    }
  }
}
