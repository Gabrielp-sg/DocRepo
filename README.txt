Plan: 5 to add, 0 to change, 0 to destroy.
╷
│ Error: Invalid count argument
│ 
│   on .terraform/modules/aws_alb_lpfat/aws_lb_listener.tf line 38, in resource "aws_lb_listener" "https_lb_listener":
│   38:   count = var.certificate_arn != null ? 1 : 0
│ 
│ The "count" value depends on resource attributes that cannot be determined
│ until apply, so Terraform cannot predict how many instances will be
│ created. To work around this, use the -target argument to first apply only
│ the resources that the count depends on.
╵
Cleaning up project directory and file based variables
