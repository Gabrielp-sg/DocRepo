resource "aws_secretsmanager_secret" "send_sftp_credentials" {
  name = format("sm-%s-%s-lpfat-send-sftp-credentials", local.workload_index, local.environment_identifier)
  tags = local.tags
}

# resource "aws_secretsmanager_secret" "send_sftp_password" {
#   name = format("sm-%s-%s-lpfat-send-sftp-password", local.workload_index, local.environment_identifier)
#   tags = local.tags
# }