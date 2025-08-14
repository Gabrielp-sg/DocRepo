data "aws_caller_identity" "caller_identity" {}

data "aws_partition" "partition" {}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_security_group" "fmm_base_security_group" {
  count = var.enable_ffm_base_security_group ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "group-name"
    values = ["FMManagedSecurityGroup*"]
  }
}

#data "aws_kms_alias" "base_kms_alias" {
#  name   = "some-key"
#}

#data "aws_kms_key" "by_alias_arn" {
#  key_id = "arn:aws:kms:eu-west-1:${local.account_id}:alias/kms-${local.workload_index}-${local.environment_identifier}-euw1-${local.kms_key1}"
#}
## kms-0046-d-euw1-key01
#data "aws_kms_key" "by_alias" {
#  key_id = "alias/kms-${local.workload_index}-${local.environment_identifier}-euw1-${local.kms_key1}"
#}

#workload_type= substr(local.workload, 5, 3)
#workload_index= substr(local.workload, 0, 4)
#environment_identifier = substr(local.environment, 0, 1)
#workload_identifier= format("%s-%s-%s", local.workload_index, local.environment_identifier, local.project)
#asg_name= format("asg-%s-%s-euw1-smtp00-lp", local.workload_index, local.environment_identifier)
#account_id= data.aws_caller_identity.current.account_id
#workload_boundary_arn= format("arn:aws:iam::%s:policy/workload-boundary", local.account_id)
