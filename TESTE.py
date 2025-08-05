START="2025-07-23T11:45:00Z"
END="2025-07-23T13:15:00Z"
SECRET_ARN="<cole_o_arn_aqui>"

SELECT eventTime, eventName,
       responseElements.versionId,
       userIdentity.type AS userType,
       userIdentity.arn  AS who,
       sourceIPAddress,
       userAgent
FROM   aws_cloudtrail_events
WHERE  eventSource = 'secretsmanager.amazonaws.com'
  AND  eventName IN ('PutSecretValue','CreateSecret')
  AND  responseElements.versionId IN (
        'ad5a6337-9d7c-496e-adda-fda5cfd6c4f7', -- AWSPREVIOUS (12:03:26Z)
        'f089c06f-46ae-4b01-945a-a03e7d89a5d0'  -- AWSCURRENT  (12:57:36Z)
      )
ORDER BY eventTime DESC;

SELECT eventTime, eventName,
       responseElements.versionId,
       userIdentity.arn, userAgent
FROM   aws_cloudtrail_events
WHERE  eventSource = 'secretsmanager.amazonaws.com'
  AND  eventName IN ('PutSecretValue','CreateSecret')
  AND  requestParameters.secretId LIKE '%lpfat-send-sftp-credentials%'
  AND  eventTime BETWEEN '2025-07-23 12:00:00' AND '2025-07-23 13:10:00'
ORDER BY eventTime;


cat /tmp/ct.json | jq -r '
  .Events[]
  | select(.EventName=="PutSecretValue" or .EventName=="CreateSecret")
  | .CloudTrailEvent
' | jq -r '
  fromjson
  | {eventTime, eventName,
     versionId: (.responseElements.versionId // .requestParameters.clientRequestToken),
     user: .userIdentity.arn,
     userType: .userIdentity.type,
     userAgent,
     sourceIP: .sourceIPAddress
  }'










ERROR! The field 'hosts' has an invalid value, which includes an undefined variable. The error was: 'target' is undefined
The error appears to be in '/runner/project/callback.yml': line 1, column 3, but may
be elsewhere in the file depending on the exact syntax problem.
The offending line appears to be:
- hosts:  "{{ target }}"
  ^ here
We could be wrong, but this one looks like it might be an issue with
missing quotes. Always quote template expression brackets when they
start a value. For instance:
    with_items:
      - {{ foo }}
Should be written as:
    with_items:
      - "{{ foo }}"

- hosts:  "{{ target }}"
  gather_facts: yes
  vars:
    ansible_aws_ssm_instance_id : "{{ instance_id }}"
  tasks:
    - name: "Install LPFAT required tools"
      include_tasks: "tasks/install_lpfat_tools.yml"
\resource "aws_secretsmanager_secret" "send_sftp_credentials" {
  name = format("sm-%s-%s-lpfat-send-sftp-credentials", local.workload_index, local.environment_identifier)
  tags = local.tags
}
Version ID
	
Staging labels
	
Last accessed
	
Created on (UTC)

ad5a6337-9d7c-496e-adda-fda5cfd6c4f7
AWSPREVIOUS
23 July 2025
23 July 2025 at 12:03:26
f089c06f-46ae-4b01-945a-a03e7d89a5d0
AWSCURRENT
5 August 2025
23 July 2025 at 12:57:36

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
