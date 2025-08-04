#################################################################
# NOTE: DO NOT MAKE CHANGES TO THIS FILE AS IT MAY BE OVERRIDEN #
#################################################################

terraform {
  backend "s3" {
    bucket         = "tfstate-497351456763"
    key            = "lpfat/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "tfstate-locking"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
