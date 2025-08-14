output "id" {
  description = "The ID of the instance."
  value       = aws_instance.instance.id
}

output "arn" {
  description = "The ARN of the instance."
  value       = aws_instance.instance.arn
}

output "capacity_reservation_specification" {
  description = "Capacity reservation specification of the instance."
  value       = aws_instance.instance.capacity_reservation_specification
}

output "instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`. See [Instance Lifecycle](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-lifecycle.html) for more information."
  value       = aws_instance.instance.instance_state
}

output "outpost_arn" {
  description = "The ARN of the Outpost the instance is assigned to."
  value       = aws_instance.instance.outpost_arn
}

output "password_data" {
  description = "Base-64 encoded encrypted password data for the instance. Useful for getting the administrator password for instances running Microsoft Windows. This attribute is only exported if `get_password_data` is true. Note that this encrypted value will be stored in the state file, as with all exported attributes. See [GetPasswordData](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_GetPasswordData.html) for more information."
  value       = aws_instance.instance.password_data
}

output "primary_network_interface_id" {
  description = "The ID of the instance's primary network interface."
  value       = aws_instance.instance.primary_network_interface_id
}

output "private_dns" {
  description = "The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC."
  value       = aws_instance.instance.private_dns
}

output "public_dns" {
  description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC."
  value       = aws_instance.instance.public_dns
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable. **NOTE**: If you are using an [`aws_eip`](/docs/providers/aws/r/eip.html) with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached."
  value       = aws_instance.instance.public_ip
}

output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = aws_instance.instance.private_ip
}

output "availability_zone" {
  description = "The availability zone of the instance."
  value       = aws_instance.instance.availability_zone
}

output "aws_instance" {
  description = "The whole resource object, see [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#attributes-reference) for more information."
  value       = aws_instance.instance
}

output "aws_iam_role" {
  description = "The whole resource object, see [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role#attributes-reference) for more information."
  value       = aws_iam_role.iam_role
}

output "aws_security_group" {
  description = "The whole resource object, see [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#attributes-reference) for more information."
  value       = aws_security_group.security_group
}
