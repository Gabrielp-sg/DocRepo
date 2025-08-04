# data "aws_secretsmanager_secret_version" "send_sftp_secret_value" {
#   secret_id = aws_secretsmanager_secret.send_sftp_credentials.name
# }

# # data "archive_file" "sftp_lambda_libs" {
# #   type = "zip"
# #   source_dir = "${path.module}/lambdas/layers/sftp/"
# #   output_path = "${path.module}/lambdas/zip/sftp.zip"
# # }

# module "aws_lambda_fetch_from_sftp" {
#   source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-lambda.git?ref=v5.1.1"

#   function_name                     = format("lambda-%s-%s-sae1-lpfat-sftp", local.workload_number, local.environment_identifier)
#   description                       = "Lambda that fetches the packages from the vendor SFTP server"
#   handler                           = "fetch_from_sftp.lambda_handler"
#   runtime                           = "python3.9"
#   lambda_package_contents           = "${path.module}/lambdas/code/sftp/" # path of your lambda code or lambda code with dependency in the repo
#   memory_size                       = 256
#   timeout                           = 900
#   publish                           = false
#   cloudwatch_logs_retention_in_days = 30
#   create_lambda_package             = true
#   create_lambda_layer_package       = true
#   create_lambda_layer               = true
#   lambda_layer_contents             = "${path.module}/lambdas/layers/sftp/" # path of your lambda layer dependency in the repo
#   lambda_layer_name                 = "lambdalayer"


#   ephemeral_storage = {
#     size = 512
#   }

#   iam_role = {
#     name = "role-0072-d-dev-lpfat-trigger"
#   }

#   environment = {
#     variables = {
#       sftp_url    = jsondecode(data.aws_secretsmanager_secret_version.send_sftp_secret_value.secret_string)["url"]
#       sftp_port   = jsondecode(data.aws_secretsmanager_secret_version.send_sftp_secret_value.secret_string)["port"]
#       sftp_user   = jsondecode(data.aws_secretsmanager_secret_version.send_sftp_secret_value.secret_string)["username"]
#       sftp_pass   = jsondecode(data.aws_secretsmanager_secret_version.send_sftp_secret_value.secret_string)["password"]
#       sftp_folder = local.environment_identifier
#     }
#   }

#   tags = local.tags
# }

# resource "aws_scheduler_schedule" "trigger_lpfat_lambda" {
#   name       = format("schedule-%s-%s-sae1-lpfat-lambda", local.workload_number, local.environment_identifier)
#   group_name = "default"

#   flexible_time_window {
#     mode = "OFF"
#   }

#   schedule_expression = "rate(30 minutes)"

#   target {
#     arn      = module.aws_lambda_fetch_from_sftp.lambda_function_arn
#     role_arn = aws_iam_role.scheduler-lpfat-lambda-role.arn
#   }
# }