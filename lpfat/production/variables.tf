variable "aws_region" {
  default = "sa-east-1"
  type    = string
}

variable "context" {
  default     = ""
  type        = string
  description = "Terraform execution context"
}
