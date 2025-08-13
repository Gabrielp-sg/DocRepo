data "aws_kinesis_firehose_delivery_stream" "waf_firehose_stream" {
  name = local.firehose_stream_for_waf_logs
}

resource "aws_wafv2_web_acl_logging_configuration" "wafv2_web_acl_logging_configuration" {
  log_destination_configs = [data.aws_kinesis_firehose_delivery_stream.waf_firehose_stream.arn]
  resource_arn            = aws_wafv2_web_acl.lpfat_web_acl.arn
}

resource "aws_wafv2_web_acl" "lpfat_web_acl" {
  name  = "lpfat_web_acl"
  scope = "REGIONAL"
  default_action {
    allow {}
  }
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 1

    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
        version     = "Version_2.0"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
        version     = "Version_1.17"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 3
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        version     = "Version_1.4"
        rule_action_override {
          action_to_use {
            count {}
          }
          name = "SizeRestrictions_BODY"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesUnixRuleSet"
    priority = 4
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
        version     = "Version_1.1"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesUnixRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 5
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
        version     = "Version_2.1"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rule-plt-geo-restriction"
    priority = 0

    override_action {
      count {}
    }

    statement {
      rule_group_reference_statement {
        arn = data.aws_wafv2_rule_group.compliant.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "plt_geo_restriction"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "PPUDRules"
    sampled_requests_enabled   = true
  }

  tags = local.tags
}

resource "aws_wafv2_web_acl_association" "alb_lpfat" {
  resource_arn = module.aws_alb_lpfat.arn
  web_acl_arn  = aws_wafv2_web_acl.lpfat_web_acl.arn
}
