resource "aws_security_group" "security_group" {
  count       = var.instance_security_group.create ? 1 : 0
  name        = var.instance_security_group.name
  name_prefix = var.instance_security_group.name_prefix
  description = coalesce(var.instance_security_group.description, format("Allow egress and ingress traffic for %s", var.name))
  vpc_id      = data.aws_vpc.vpc.id
  tags        = merge({ Name : var.instance_security_group.name }, local.tags, var.instance_security_group.tags)
}

resource "aws_security_group_rule" "egress_security_group_rules" {
  for_each                 = { for key, value in coalesce(var.instance_security_group.egress_rules, []) : key => value }
  type                     = "egress"
  security_group_id        = aws_security_group.security_group[0].id
  from_port                = each.value.from_port
  to_port                  = coalesce(each.value.to_port, each.value.from_port)
  protocol                 = coalesce(each.value.protocol, "tcp")
  cidr_blocks              = each.value.cidr_blocks
  description              = each.value.description
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  self                     = each.value.self
  source_security_group_id = each.value.source_security_group_id
}

resource "aws_security_group_rule" "ingress_security_group_rules" {
  for_each                 = { for key, value in coalesce(var.instance_security_group.ingress_rules, []) : key => value }
  type                     = "ingress"
  security_group_id        = aws_security_group.security_group[0].id
  from_port                = each.value.from_port
  to_port                  = coalesce(each.value.to_port, each.value.from_port)
  protocol                 = coalesce(each.value.protocol, "tcp")
  cidr_blocks              = each.value.cidr_blocks
  description              = each.value.description
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  self                     = each.value.self
  source_security_group_id = each.value.source_security_group_id
}

resource "aws_security_group_rule" "default_egress_security_group_rules" {
  for_each = { for key, value in var.default_instance_security_group_rules.egress_rules : key => value
    if var.instance_security_group.create == true
  }
  type              = "egress"
  security_group_id = aws_security_group.security_group[0].id
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  cidr_blocks       = each.value.cidr_blocks
}

resource "aws_security_group_rule" "default_ingress_security_group_rules" {
  for_each = { for key, value in var.default_instance_security_group_rules.ingress_rules : key => value
    if var.instance_security_group.create == true
  }
  type              = "ingress"
  security_group_id = aws_security_group.security_group[0].id
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  cidr_blocks       = each.value.cidr_blocks
}
