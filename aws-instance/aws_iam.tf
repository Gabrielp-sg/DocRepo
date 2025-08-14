data "aws_iam_policy_document" "assume_role_iam_policy_document" {
  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = formatlist("ec2.%s", data.aws_partition.partition.dns_suffix)
    }
  }
}

resource "aws_iam_role" "iam_role" {
  count                 = var.iam_instance_profile == null ? 1 : 0
  name                  = var.iam_role.name
  name_prefix           = var.iam_role.name_prefix
  path                  = var.iam_role.path
  description           = var.iam_role.description
  assume_role_policy    = data.aws_iam_policy_document.assume_role_iam_policy_document.json
  permissions_boundary  = coalesce(var.iam_role.permissions_boundary, format("arn:aws:iam::%s:policy/workload-boundary", data.aws_caller_identity.caller_identity.account_id))
  force_detach_policies = coalesce(var.iam_role.force_detach_policies, true)
  tags                  = merge(local.tags, coalesce(var.iam_role.tags, {}))
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  for_each = {
    for key, value in concat([format("arn:aws:iam::%s:policy/plt-instance-profile-policy", data.aws_caller_identity.caller_identity.account_id)], var.aws_managed_iam_policy_arns, coalesce(var.iam_role.policy_arns, [])) : key => value #OPA0201
    if var.iam_instance_profile == null
  }
  policy_arn = each.value
  role       = aws_iam_role.iam_role[0].name
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  count       = var.iam_instance_profile == null ? 1 : 0
  role        = aws_iam_role.iam_role[0].name
  name        = coalesce(var.iam_role.name, format("%s-instance-iam-role", var.name))
  name_prefix = var.iam_role.name_prefix
  path        = var.iam_role.path
  tags        = merge(local.tags, var.iam_role.tags)
  lifecycle {
    create_before_destroy = true
  }
}
