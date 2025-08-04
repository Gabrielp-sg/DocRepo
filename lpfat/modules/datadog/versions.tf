terraform {
  required_providers {
    datadog = {
      # changelog at https://github.com/DataDog/terraform-provider-datadog/blob/master/CHANGELOG.md
      source  = "DataDog/datadog"
      version = "3.18.0"
    }
  }
}
