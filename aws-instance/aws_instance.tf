resource "aws_instance" "instance" {
  ami                         = var.ami
  associate_public_ip_address = false # OPA301 https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204405770/OPA+Rules+0200-0399#OPA0301
  availability_zone           = var.availability_zone
  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification.capacity_reservation_preference != null ? [var.capacity_reservation_specification.capacity_reservation_preference] : []
    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference
    }
  }
  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification.capacity_reservation_target != null ? [var.capacity_reservation_specification.capacity_reservation_target] : []
    content {
      capacity_reservation_target {
        capacity_reservation_id                 = capacity_reservation_specification.value.capacity_reservation_id
        capacity_reservation_resource_group_arn = capacity_reservation_specification.value.capacity_reservation_resource_group_arn

      }
    }
  }
  cpu_core_count       = var.cpu_core_count
  cpu_threads_per_core = var.cpu_threads_per_core
  credit_specification {
    cpu_credits = var.credit_specification.cpu_credits
  }
  disable_api_stop        = var.disable_api_stop
  disable_api_termination = var.disable_api_termination

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      delete_on_termination = ebs_block_device.value.delete_on_termination
      device_name           = ebs_block_device.value.device_name
      encrypted             = ebs_block_device.value.encrypted
      iops                  = ebs_block_device.value.iops
      kms_key_id            = ebs_block_device.value.kms_key_id
      snapshot_id           = ebs_block_device.value.snapshot_id
      throughput            = ebs_block_device.value.throughput
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
      tags                  = merge({ Name = var.name }, ebs_block_device.value.tags, local.tags) # TODO: check if we should merge tags?
    }
  }

  ebs_optimized = var.ebs_optimized
  enclave_options {
    enabled = var.enclave_options.enabled
  }
  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_devices
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = ephemeral_block_device.value.no_device
      virtual_name = ephemeral_block_device.value.virtual_name
    }
  }
  get_password_data                    = var.get_password_data
  hibernation                          = var.hibernation
  host_id                              = var.host_id
  iam_instance_profile                 = try(aws_iam_instance_profile.iam_instance_profile[0].name, var.iam_instance_profile)
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  ipv6_address_count                   = var.ipv6_address_count
  ipv6_addresses                       = var.ipv6_addresses
  key_name                             = var.key_name

  dynamic "launch_template" {
    for_each = var.launch_template.id != null ? [var.launch_template] : []
    content {
      id      = launch_template.value.id
      version = launch_template.value.version
    }
  }
  dynamic "launch_template" {
    for_each = var.launch_template.name != null ? [var.launch_template] : []
    content {
      name    = launch_template.value.name
      version = launch_template.value.version
    }
  }
  maintenance_options {
    auto_recovery = var.maintenance_options.auto_recovery
  }
  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    http_tokens                 = coalesce(var.metadata_options.http_tokens, "required") # OPA303 https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204405770/OPA+Rules+0200-0399#OPA0303
    instance_metadata_tags      = var.metadata_options.instance_metadata_tags
  }
  monitoring = var.monitoring
  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      delete_on_termination = network_interface.value.delete_on_termination
      device_index          = network_interface.value.device_index
      network_card_index    = network_interface.value.network_card_index
      network_interface_id  = network_interface.value.network_interface_id
    }
  }
  placement_group            = var.placement_group
  placement_partition_number = var.placement_partition_number
  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = var.private_dns_name_options.enable_resource_name_dns_aaaa_record
    enable_resource_name_dns_a_record    = var.private_dns_name_options.enable_resource_name_dns_a_record
    hostname_type                        = var.private_dns_name_options.hostname_type
  }
  private_ip = var.private_ip

  root_block_device {
    delete_on_termination = var.root_block_device.delete_on_termination
    encrypted             = var.root_block_device.encrypted
    iops                  = var.root_block_device.iops
    kms_key_id            = var.root_block_device.kms_key_id
    throughput            = var.root_block_device.throughput
    volume_size           = var.root_block_device.volume_size
    volume_type           = var.root_block_device.volume_type
    tags                  = merge({ Name = var.name }, var.root_block_device.tags, local.tags) # TODO: check if we should merge tags?
  }

  secondary_private_ips       = var.secondary_private_ips
  source_dest_check           = var.source_dest_check
  subnet_id                   = var.subnet_id
  tags                        = merge({ Name = var.name }, local.tags)
  tenancy                     = var.tenancy
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change
  vpc_security_group_ids      = concat(compact([try(aws_security_group.security_group[0].id, ""), join("", data.aws_security_group.fmm_base_security_group[*].id)]), try(var.vpc_security_group_ids, ""))
}
