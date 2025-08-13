terraform {
  required_version = "~> 1.9.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.21.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "3.44.1"
    }
  }
}
