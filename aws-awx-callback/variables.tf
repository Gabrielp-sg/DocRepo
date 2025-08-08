variable "os_type" {
  description = "Operating system to render the template"
  type        = string
  nullable    = false
  validation {
    condition     = contains(["rhel", "windows", "al2"], var.os_type)
    error_message = "The `os_type` must be (rhel, windows, al2)."
  }
}

variable "template_id" {
  description = "AWX template ID"
  type        = number
  nullable    = false
  validation {
    condition     = var.template_id >= 0 && var.template_id <= 9999
    error_message = "The `template_id` must be between 1-9999."
  }
}

variable "workload_number" {
  description = "Unique 4-digit unique number that identifies the unique-numbering-index for the associated workload account."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9]{4}$", var.workload_number))
    error_message = "The `workload_number` must be unique-numbering-index described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention)."
  }
}

variable "workload_type" {
  description = "Workload type"
  type        = string
  default     = "wkl"
  nullable    = false
  validation {
    condition     = contains(["wkl", "svc"], var.workload_type)
    error_message = "The `workload_type` must be wkl or svc."
  }
}

variable "environment_id" {
  description = "Single letter identifier of DTAP environment [d|t|a|p]"
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[dtapm]$", var.environment_id))
    error_message = "The `environment_id` must be [d|t|a|p|m]. It's described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention)."

  }
}

variable "extra_vars" {
  description = "Extra vars to pass to AWX"
  type        = map(any)
  default     = {}
  nullable    = true
}

variable "region" {
  description = "Pass Region then default value"
  type        = string
  default     = "eu-west-1"
  nullable    = false
}
