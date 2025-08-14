variable "name" {
  description = "(Required) Name to be used on all resources as prefix"
  type        = string
  nullable    = false
}

# AWS Instance
# https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204405770/OPA+Rules+0200-0399#OPA0300
variable "ami" {
  description = "(Optional) AMI to use for the instance. Required unless `launch_template` is specified and the Launch Template specifies an AMI. If an AMI is specified in the Launch Template, setting `ami` will override the AMI specified in the Launch Template."
  type        = string
  default     = null
  validation {
    condition     = var.ami == null || can(regex("^ami-[0-9a-z]+$", var.ami))
    error_message = "`ami` must be a valid AWS AMI."
  }
}

variable "availability_zone" {
  description = "(Optional) AZ to start the instance in."
  type        = string
  default     = null
  validation {
    condition     = var.availability_zone == null || can(regex("^[[:lower:]]{2}-[[:lower:]]+-[1-9]+[[:lower:]]+$", var.availability_zone))
    error_message = "`availability_zone` must be a valid AWS AZ, see [AWS Availability Zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html)."
  }
}

variable "capacity_reservation_specification" {
  description = "(Optional) Describes an instance's Capacity Reservation targeting option. See [Capacity Reservation Specification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#capacity-reservation-specification) below for more details."
  type = object({
    capacity_reservation_preference = optional(string)           # (Optional) Indicates the instance's Capacity Reservation preferences. Can be "open" or "none". (Default: "open").
    capacity_reservation_target = optional(object({              # (Optional) Information about the target Capacity Reservation. See [Capacity Reservation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#capacity-reservation-target) Target below for more details.
      capacity_reservation_id                 = optional(string) # (Optional) The ID of the Capacity Reservation in which to run the instance.
      capacity_reservation_resource_group_arn = optional(string) # (Optional) The ARN of the Capacity Reservation resource group in which to run the instance.
    }))
  })
  default = {}
  validation {
    condition     = var.capacity_reservation_specification.capacity_reservation_preference == null || can(regex("^(open|none)$", var.capacity_reservation_specification.capacity_reservation_preference))
    error_message = "`capacity_reservation_specification.capacity_reservation_preference` can be `open` or `none`."
  }
  validation {
    condition     = var.capacity_reservation_specification.capacity_reservation_target == null || try(var.capacity_reservation_specification.capacity_reservation_target.capacity_reservation_resource_group_arn, null) == null || can(regex("^arn:aws:resource-groups:[[:lower:]]{2}-[[:lower:]]+-[1-9]:[[:digit:]]{12}:group/[0-9A-Za-z_-]+$", var.capacity_reservation_specification.capacity_reservation_target.capacity_reservation_resource_group_arn))
    error_message = "`var.capacity_reservation_specification.capacity_reservation_target.capacity_reservation_resource_group_arn` must be a valid AWS Capacity Reservation Resource Group ARN (arn:aws:resource-groups:sa-east-1:123456789012:group/MyCRGroup), see [Work with Capacity Reservation groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-cr-group.html)."
  }
}

variable "cpu_core_count" {
  description = "(Optional) Sets the number of CPU cores for an instance. This option is only supported on creation of instance type that support CPU Options [CPU Cores and Threads Per CPU Core Per Instance Type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-optimize-cpu.html#cpu-options-supported-instances-values), specifying this option for unsupported instance types will return an error from the EC2 API. **NOTE:** Changing `cpu_core_count` and/or `cpu_threads_per_core` will cause the resource to be destroyed and re-created."
  type        = number
  default     = null
}

variable "cpu_threads_per_core" {
  description = "(Optional - has no effect unless `cpu_core_count` is also set)  If set to to 1, hyperthreading is disabled on the launched instance. Defaults to 2 if not set. See [Optimizing CPU Options](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-optimize-cpu.html) for more information."
  type        = number
  default     = null
}

variable "credit_specification" {
  description = "(Optional) Configuration block for customizing the credit specification of the instance. See [Credit Specification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#credit-specification) below for more details. Terraform will only perform drift detection of its value when present in a configuration. Removing this configuration on existing instances will only stop managing it. It will not change the configuration back to the default for the instance type."
  type = object({
    cpu_credits = optional(string) # (Optional) Credit option for CPU usage. Valid values include standard or unlimited. T3 instances are launched as unlimited by default. T2 instances are launched as standard by default.
  })
  default = {}
  validation {
    condition     = var.credit_specification.cpu_credits == null || can(regex("^(standard|unlimited)$", var.credit_specification.cpu_credits))
    error_message = "`credit_specification.cpu_credits` can be `standard` or `unlimited`."
  }
}

variable "disable_api_stop" {
  description = "(Optional) If true, enables [EC2 Instance Stop Protection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Stop_Start.html#Using_StopProtection)."
  type        = bool
  default     = null
}

variable "disable_api_termination" {
  description = "(Optional) If true, enables [EC2 Instance Termination Protection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingDisableAPITermination)."
  type        = bool
  default     = null
}

variable "ebs_block_devices" {
  description = "(Optional) One or more configuration blocks with additional EBS block devices to attach to the instance. Block device configurations only apply on resource creation, adding this block in an already existing instance, will trigger the resource recreation. See [Block Devices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#ebs-ephemeral-and-root-block-devices) below for details on attributes and drift detection. When accessing this as an attribute reference, it is a set of objects."
  type = list(object({
    #    Each ebs_block_device block supports the following:
    delete_on_termination = optional(bool)        # (Optional) Whether the volume should be destroyed on instance termination. Defaults to true.
    device_name           = string                # (Required) Name of the device to mount. E.g., /dev/sdh or xvdh.
    encrypted             = optional(bool)        # (Optional) Enables [EBS encryption](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html) on the volume. Defaults to false. Cannot be used with snapshot_id. Must be configured to perform drift detection. # TODO: if we should not be supporting snapshot_id encrypted should be hardcoded to true (do not expose it to the module users).
    iops                  = optional(number)      # (Optional) Amount of provisioned [IOPS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-io-characteristics.html). Only valid for volume_type of io1, io2 or gp3.
    kms_key_id            = optional(string)      # (Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. Must be configured to perform drift detection.
    snapshot_id           = optional(string)      # (Optional) Snapshot ID to mount. # TODO: check if we should be supporting snapshot_id, is this allowed?
    tags                  = optional(map(string)) # (Optional) A map of tags to assign to the device.
    throughput            = optional(number)      # (Optional) Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of gp3.
    volume_size           = optional(number)      # (Optional) Size of the volume in gibibytes (GiB).
    volume_type           = optional(string)      # (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp2.
  }))
  default = []
  validation {
    condition = length([
      for ebs_block_device in var.ebs_block_devices : true
      if ebs_block_device.encrypted == null || (ebs_block_device.encrypted == true && ebs_block_device.snapshot_id == null)
    ]) == length(var.ebs_block_devices)
    error_message = "`ebs_block_devices.*.encrypted` can be set only when `ebs_block_devices.*.snapshot_id` is not used."
  }
  validation {
    condition = length([
      for ebs_block_device in var.ebs_block_devices : true
      if ebs_block_device.iops == null || (ebs_block_device.iops != null && contains(["io1", "io2", "gp3"], ebs_block_device.volume_type))
    ]) == length(var.ebs_block_devices)
    error_message = "`ebs_block_devices.*.iops` can be set only when `ebs_block_devices.*.volume_type` is `io1`, `io2` or `gp3`."
  }
  validation {
    condition = length([
      for ebs_block_device in var.ebs_block_devices : true
      if ebs_block_device.kms_key_id == null || can(regex("^arn:aws:kms:[[:lower:]]{2}-[[:lower:]]+-[1-9]:[[:digit:]]{12}:key/[a-z0-9-]+$", ebs_block_device.kms_key_id))
    ]) == length(var.ebs_block_devices)
    error_message = "`ebs_block_devices.*.kms_key_id` must be a list of valid AWS KMS key ARN (arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab), see [IAM identifiers](https://docs.aws.amazon.com/kms/latest/developerguide/find-cmk-id-arn.html)."
  }
  validation {
    condition = length([
      for ebs_block_device in var.ebs_block_devices : true
      if ebs_block_device.throughput == null || (ebs_block_device.throughput != null && ebs_block_device.volume_type == "gp3")
    ]) == length(var.ebs_block_devices)
    error_message = "`ebs_block_devices.*.throughput` can be set only when `ebs_block_devices.*.volume_type` is `gp3`."
  }
  validation {
    condition = length([
      for ebs_block_device in var.ebs_block_devices : true
      if ebs_block_device.volume_type == null || can(regex("^(standard|gp2|gp3|io1|io2|sc1|st1)$", ebs_block_device.volume_type))
    ]) == length(var.ebs_block_devices)
    error_message = "`ebs_block_devices.*.throughput` can be `standard`, `gp2`, `gp3`, `io1`, `io2`, `sc1`, or `st1`."
  }
}

variable "additional_disks" {
  description = "(Optional) One or more disks configuration blocks."
  type = list(object({
    device_name = string                # (Required) Name of the device to mount. E.g., /dev/sdh or xvdh.
    encrypted   = optional(bool)        # (Optional) Enables [EBS encryption](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html) on the volume. Defaults to false. Cannot be used with snapshot_id. Must be configured to perform drift detection. # TODO: if we should not be supporting snapshot_id encrypted should be hardcoded to true (do not expose it to the module users).
    iops        = optional(number)      # (Optional) Amount of provisioned [IOPS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-io-characteristics.html). Only valid for volume_type of io1, io2 or gp3.
    kms_key_id  = optional(string)      # (Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. Must be configured to perform drift detection.
    snapshot_id = optional(string)      # (Optional) Snapshot ID to mount. # TODO: check if we should be supporting snapshot_id, is this allowed?
    throughput  = optional(number)      # (Optional) Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of gp3.
    size        = optional(number)      # (Optional) Size of the volume in gibibytes (GiB).
    type        = optional(string)      # (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp2.
    tags        = optional(map(string)) # (Optional) A map of tags to assign to the device.
  }))
  default = []
  validation {
    condition = length([
      for addition_disk in var.additional_disks : true
      if addition_disk.encrypted == null || (addition_disk.encrypted == true && addition_disk.snapshot_id == null)
    ]) == length(var.additional_disks)
    error_message = "`additional_disks.*.encrypted` can be set only when `additional_disks.*.snapshot_id` is not used."
  }
  validation {
    condition = length([
      for addition_disk in var.additional_disks : true
      if addition_disk.iops == null || (addition_disk.iops != null && contains(["io1", "io2", "gp3"], addition_disk.type))
    ]) == length(var.additional_disks)
    error_message = "`additional_disks.*.iops` can be set only when `additional_disks.*.type` is `io1`, `io2` or `gp3`."
  }
  validation {
    condition = length([
      for addition_disk in var.additional_disks : true
      if addition_disk.kms_key_id == null || can(regex("^arn:aws:kms:[[:lower:]]{2}-[[:lower:]]+-[1-9]:[[:digit:]]{12}:key/[a-z0-9-]+$", addition_disk.kms_key_id))
    ]) == length(var.additional_disks)
    error_message = "`additional_disks.*.kms_key_id` must be a list of valid AWS KMS key ARN (arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab), see [IAM identifiers](https://docs.aws.amazon.com/kms/latest/developerguide/find-cmk-id-arn.html)."
  }
  validation {
    condition = length([
      for addition_disk in var.additional_disks : true
      if addition_disk.throughput == null || (addition_disk.throughput != null && addition_disk.type == "gp3")
    ]) == length(var.additional_disks)
    error_message = "`additional_disks.*.throughput` can be set only when `additional_disks.*.volume_type` is `gp3`."
  }
  validation {
    condition = length([
      for addition_disk in var.additional_disks : true
      if addition_disk.type == null || can(regex("^(standard|gp2|gp3|io1|io2|sc1|st1)$", addition_disk.type))
    ]) == length(var.additional_disks)
    error_message = "`additional_disks.*.throughput` can be `standard`, `gp2`, `gp3`, `io1`, `io2`, `sc1`, or `st1`."
  }
}

variable "ebs_optimized" {
  description = "(Optional) If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. See the [EBS Optimized section](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSOptimized.html) of the AWS User Guide for more information."
  type        = bool
  default     = null
}

variable "enclave_options" {
  description = "(Optional) Enable Nitro Enclaves on launched instances. See [Enclave Options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#enclave-options) below for more details."
  type = object({
    # The enclave_options block supports the following:
    enabled = optional(bool) # (Optional) Whether Nitro Enclaves will be enabled on the instance. Defaults to false. For more information, see the documentation on [Nitro Enclaves](https://docs.aws.amazon.com/enclaves/latest/user/nitro-enclave.html).
  })
  default = {}
}

variable "ephemeral_block_devices" {
  description = "(Optional) One or more configuration blocks to customize Ephemeral (also known as 'Instance Store') volumes on the instance. See [Block Devices](#ebs-ephemeral-and-root-block-devices) below for details. When accessing this as an attribute reference, it is a set of objects."
  type = list(object({
    # Each ephemeral_block_device block supports the following:
    device_name  = string           #  The name of the block device to mount on the instance.
    no_device    = optional(bool)   #  (Optional) Suppresses the specified device included in the AMI's block device mapping.
    virtual_name = optional(string) #  (Optional) [Instance Store Device Name](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html#InstanceStoreDeviceNames) (e.g., ephemeral0).
  }))
  default = []
}

variable "get_password_data" {
  description = "(Optional) If true, wait for password data to become available and retrieve it. Useful for getting the administrator password for instances running Microsoft Windows. The password data is exported to the `password_data` attribute. See [GetPasswordData](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_GetPasswordData.html) for more information."
  type        = bool
  default     = null
}

variable "hibernation" {
  description = "(Optional) If true, the launched EC2 instance will support hibernation."
  type        = bool
  default     = null
}

variable "host_id" {
  description = "(Optional) ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host."
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "(Optional) IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. Ensure your credentials have the correct permission to assign the instance profile according to the [EC2 documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html#roles-usingrole-ec2instance-permissions), notably `iam:PassRole`."
  type        = string
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "(Optional) Shutdown behavior for the instance. Amazon defaults this to `stop` for EBS-backed instances and `terminate` for instance-store instances. Cannot be set on instance-store instances. See [Shutdown Behavior](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior) for more information."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "(Optional) The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance. See [allowed_instance_types](https://gitlab.core-services.leaseplan.systems/scp-management/scp-manager/-/blob/master/src/scp_manager/scp_defaults.py) in Landing Zone, by default the following instances are allowed: c5.*, c5a.*, c5ad.*, c5d.*, c6g.*, m5.*, m5a.*, m5ad.*, m5d.*, m5zn.*, m6g.*, r5.*, r5a.*, r5ad.*, r5b.*, r5d.*, r6g.*, t3.*, t3a.* and t4g.*."
  type        = string
  default     = null
}

variable "ipv6_address_count" {
  description = "(Optional) A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet."
  type        = number
  default     = null
}

variable "ipv6_addresses" {
  description = "(Optional) Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "(Optional) Key name of the Key Pair to use for the instance; which can be managed using [the `aws_key_pair` resource](key_pair.html)."
  type        = string
  default     = null
}

variable "launch_template" {
  description = "(Optional) Specifies a Launch Template to configure the instance. Parameters configured on this resource will override the corresponding parameters in the Launch Template. See [Launch Template Specification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#launch-template-specification) below for more details."
  type = object({
    # The launch_template block supports the following:
    id      = optional(string) # The ID of the launch template. Conflicts with name.
    name    = optional(string) # The name of the launch template. Conflicts with id.
    version = string           # Template version. Can be a specific version number, $Latest or $Default. The default value is $Default.
  })
  default = {
    version = null
    id      = null
    name    = null
  }
  validation {
    condition     = (var.launch_template.id == null || var.launch_template.name == null) || (var.launch_template.id == null && var.launch_template.name != null) || (var.launch_template.id != null && var.launch_template.name == null)
    error_message = "`launch_template.id` and `launch_template.name` can't be set at the same time, choose one."
  }
  validation {
    condition     = var.launch_template.version == null || can(regex("^(\\$Latest|\\$Default|[[:digit:]]+)$", var.launch_template.version))
    error_message = "`launch_template.version` can be `$Latest`, `$Default`, or a version number."
  }
}

variable "maintenance_options" {
  description = "(Optional) The maintenance and recovery options for the instance. See [Maintenance Options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#maintenance-options) below for more details."
  type = object({
    #  The maintenance_options block supports the following:
    auto_recovery = optional(string) # (Optional) The automatic recovery behavior of the Instance. Can be "default" or "disabled". See Recover your instance for more details.
  })
  default = {}
  validation {
    condition     = var.maintenance_options.auto_recovery == null || can(regex("^(default|disabled)$", var.maintenance_options.auto_recovery))
    error_message = "`maintenance_options.auto_recovery` can be `default`, or `disabled`."
  }
}

variable "metadata_options" {
  description = "(Optional) Customize the metadata options of the instance. See [Metadata Options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#metadata-options) below for more details."
  type = object({
    # The metadata_options block supports the following:
    http_endpoint               = optional(string) # (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled.
    http_put_response_hop_limit = optional(number) # (Optional) Desired HTTP PUT response hop limit for instance metadata requests. The larger the number, the further instance metadata requests can travel. Valid values are integer from 1 to 64. Defaults to 1.
    http_tokens                 = optional(string) # (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to required.
    instance_metadata_tags      = optional(string) # (optional) Enables or disables access to instance tags from the instance metadata service. Valid values include enabled or disabled. Defaults to disabled.
  })
  default = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  validation {
    condition     = var.metadata_options.http_endpoint == null || can(regex("^(enabled|disabled)$", var.metadata_options.http_endpoint))
    error_message = "`metadata_options.http_endpoint` can be `enabled`, or `disabled`."
  }
  validation {
    condition     = contains(range(1, 65), var.metadata_options.http_put_response_hop_limit != null ? var.metadata_options.http_put_response_hop_limit : 1)
    error_message = "`metadata_options.http_put_response_hop_limit` can be between `1`, or `64`."
  }
  validation {
    condition     = var.metadata_options.http_tokens == null || can(regex("^(optional|required)$", var.metadata_options.http_tokens))
    error_message = "`metadata_options.http_tokens` can be `optional`, or `required`."
  }
  validation {
    condition     = var.metadata_options.instance_metadata_tags == null || can(regex("^(enabled|disabled)$", var.metadata_options.instance_metadata_tags))
    error_message = "`metadata_options.instance_metadata_tags` can be `enabled`, or `disabled`."
  }
}

variable "monitoring" {
  description = "(Optional) If true, the launched EC2 instance will have detailed monitoring enabled. (Available since v0.6.0)"
  type        = bool
  default     = null
}

variable "network_interface" {
  description = "(Optional) Customize network interfaces to be attached at instance boot time. See [Network Interfaces](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#network-interfaces) below for more details."
  type = list(object({
    # Each network_interface block supports the following:
    delete_on_termination = optional(bool)   # (Optional) Whether or not to delete the network interface on instance termination. Defaults to false. Currently, the only valid value is false, as this is only supported when creating new network interfaces when launching an instance.
    device_index          = number           # (Required) Integer index of the network interface attachment. Limited by instance type.
    network_card_index    = optional(number) # (Optional) Integer index of the network card. Limited by instance type. The default index is 0.
    network_interface_id  = string           # (Required) ID of the network interface to attach.
  }))
  default = []
}

variable "placement_group" {
  description = "(Optional) Placement Group to start the instance in."
  type        = string
  default     = null
}

variable "placement_partition_number" {
  description = "(Optional) The number of the partition the instance is in. Valid only if [the `aws_placement_group` resource's](placement_group.html) `strategy` argument is set to `'partition'`."
  type        = number
  default     = null
}

variable "private_dns_name_options" {
  description = "(Optional) The options for the instance hostname. The default values are inherited from the subnet. See [Private DNS Name Options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#private-dns-name-options) below for more details."
  type = object({
    # The private_dns_name_options block supports the following:
    enable_resource_name_dns_aaaa_record = bool   # Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records.
    enable_resource_name_dns_a_record    = bool   # Indicates whether to respond to DNS queries for instance hostnames with DNS A records.
    hostname_type                        = string # The type of hostname for Amazon EC2 instances. For IPv4 only subnets, an instance DNS name must be based on the instance IPv4 address. For IPv6 native subnets, an instance DNS name must be based on the instance ID. For dual-stack subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: ip-name and resource-name.
  })
  default = {
    enable_resource_name_dns_aaaa_record = null
    enable_resource_name_dns_a_record    = null
    hostname_type                        = null
  }
  validation {
    condition     = var.private_dns_name_options.hostname_type == null || can(regex("^(ip-name|resource-name)$", var.private_dns_name_options.hostname_type))
    error_message = "`private_dns_name_options.instance_metadata_tags` can be `ip-name`, or `resource-name`."
  }
}

variable "private_ip" {
  description = "(Optional) Private IP address to associate with the instance in a VPC."
  type        = string
  default     = null
}

variable "root_block_device" {
  description = "(Optional) Configuration block to customize details about the root block device of the instance. See [Block Devices](#ebs-ephemeral-and-root-block-devices) below for details. When accessing this as an attribute reference, it is a list containing one object."
  type = object({
    #  The root_block_device block supports the following:
    delete_on_termination = optional(bool)        # (Optional) Whether the volume should be destroyed on instance termination. Defaults to true.
    encrypted             = optional(bool)        # (Optional) Whether to enable volume encryption. Defaults to false. Must be configured to perform drift detection.
    iops                  = optional(string)      # (Optional) Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3.
    kms_key_id            = optional(string)      # (Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. Must be configured to perform drift detection.
    tags                  = optional(map(string)) # (Optional) A map of tags to assign to the device.
    throughput            = optional(string)      # (Optional) Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of gp3.
    volume_size           = optional(string)      # (Optional) Size of the volume in gibibytes (GiB).
    volume_type           = optional(string)      # (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp2.
  })
  default = {}
  validation {
    condition     = var.root_block_device == null || var.root_block_device.iops == null || can(regex("^(io1|io2|gp3)$", var.root_block_device.iops))
    error_message = "`root_block_device.*.iops` can be `io1`, `io2` or `gp3`."
  }
  validation {
    condition     = var.root_block_device == null || var.root_block_device.kms_key_id == null || can(regex("^arn:aws:kms:[[:lower:]]{2}-[[:lower:]]+-[1-9]:[[:digit:]]{12}:key/[a-z0-9\\-]+", var.root_block_device.kms_key_id))
    error_message = "`root_block_device.kms_key_id` must be a list of valid AWS KMS key ARN (arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab), see [IAM identifiers](https://docs.aws.amazon.com/kms/latest/developerguide/find-cmk-id-arn.html)."
  }
  validation {
    condition     = var.root_block_device == null || var.root_block_device.throughput == null || (var.root_block_device.throughput != null && var.root_block_device.volume_type == "gp3")
    error_message = "`root_block_device.throughput` can be set only when `root_block_devices.volume_type` is `gp3`."
  }
  validation {
    condition     = var.root_block_device == null || var.root_block_device.volume_type == null || can(regex("^(standard|gp2|gp3|io1|io2|sc1|st1)$", var.root_block_device.volume_type))
    error_message = "`root_block_devices.volume_type` can be `standard`, `gp2`, `gp3`, `io1`, `io2`, `sc1`, or `st1`."
  }
}

variable "secondary_private_ips" {
  description = "(Optional) A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e., referenced in a `network_interface` block. Refer to the [Elastic network interfaces documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI) to see the maximum number of private IP addresses allowed per instance type."
  type        = list(string)
  default     = []
}

variable "source_dest_check" {
  description = "(Optional) Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. Defaults true."
  type        = bool
  default     = null
}

variable "vpc_id" {
  description = "(Optional) VPC ID used for the security group."
  type        = string
  default     = null
  validation {
    condition     = var.vpc_id == null || can(regex("^vpc-[a-z0-9-]+$", var.vpc_id))
    error_message = "`vpc_id` must be a valid AWS VPC ID `vpc_id-123456890`."
  }
}

variable "subnet_id" {
  description = "(Optional) VPC Subnet ID to launch in."
  type        = string
  default     = null
  validation {
    condition     = var.subnet_id == null || can(regex("^subnet-[a-z0-9-]+$", var.subnet_id))
    error_message = "`subnet_id` must be a valid AWS VPC Subnet ID `subnet-123456890`."
  }
}

variable "enable_ffm_base_security_group" {
  description = "(Optional) Whether to enable the AWS Firewall Manager Security Group."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resources created by this module. If configured with a provider [`default_tags` configuration block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags) present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map(string)
  default     = {}
}

variable "tenancy" {
  description = "(Optional) Tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command."
  type        = string
  default     = null
}

variable "user_data" {
  description = "(Optional) User data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see `user_data_base64` instead. Updates to this field will trigger a stop/start of the EC2 instance by default. If the `user_data_replace_on_change` is set then updates to this field will trigger a destroy and recreate."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "(Optional) Can be used instead of `user_data` to pass base64-encoded binary data directly. Use this instead of `user_data` whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption. Updates to this field will trigger a stop/start of the EC2 instance by default. If the `user_data_replace_on_change` is set then updates to this field will trigger a destroy and recreate."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "(Optional) When used in combination with `user_data` or `user_data_base64` will trigger a destroy and recreate when set to `true`. Defaults to `false` if not set."
  type        = bool
  default     = null
}

variable "vpc_security_group_ids" {
  description = "(Optional, VPC only) A list of security group IDs to associate with the instance."
  type        = list(string)
  default     = []
  validation {
    condition = length([
      for vpc_security_group_id in var.vpc_security_group_ids : true
      if can(regex("^sg-[a-z0-9-]+$", vpc_security_group_id))
    ]) == length(var.vpc_security_group_ids)
    error_message = "`vpc_security_group_ids.*` must be a valid AWS VPC Security Group ID `sg-123456890`."
  }
}

# Security Group
# https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2224145774/OPA+Rules+0500-0599#OPA0500
variable "instance_security_group" {
  description = "(Optional) Default instance Security Group and Security Group Rules. The following egress are added as defaults, allow 53(DNS), 80(HTTP) and 443(HTTPS) to the internet(0.0.0.0/0)."
  type = object({
    create      = optional(bool, true) # (Optional, default true) Create default security group.
    name        = optional(string)     # (Required, Forces new resource) Name of the security group. Conflicts with `name_prefix`. Follow the naming convention described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention#Security-Groups)
    name_prefix = optional(string)     # (Optional, Forces new resource) Name prefix of the security group. Conflicts with `name`. Can help avoid the Security Group Deletion Problem by using it instead of name.
    description = optional(string)     # (Optional, Forces new resource) Security group description. Defaults to Managed by Terraform. Cannot be "". NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags.
    ingress_rules = optional(list(object({
      from_port                = string                 # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
      to_port                  = optional(string)       # (Optional) Uses from_port if not defined. End port (or ICMP code if protocol is "icmp").
      protocol                 = optional(string)       # (Optional) Defaults to tcp. If not icmp, icmpv6, tcp, udp, or all use the protocol number
      cidr_blocks              = optional(list(string)) # (Optional) List of CIDR blocks. Cannot be specified with source_security_group_id or self.
      description              = optional(string)       # (Optional) Description of the rule.
      ipv6_cidr_blocks         = optional(list(string)) # (Optional) List of IPv6 CIDR blocks. Cannot be specified with source_security_group_id or self.
      prefix_list_ids          = optional(list(string)) # (Optional) List of Prefix List IDs.
      self                     = optional(bool)         # (Optional) Whether the security group itself will be added as a source to this ingress rule. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or source_security_group_id.
      source_security_group_id = optional(string)       # (Optional) Security group id to allow access to/from, depending on the type. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or self.
    })))
    egress_rules = optional(list(object({
      from_port                = string                 # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
      to_port                  = optional(string)       # (Optional) Uses from_port if not defined. End port (or ICMP code if protocol is "icmp").
      protocol                 = optional(string)       # (Optional) Defaults to tcp. If not icmp, icmpv6, tcp, udp, or all use the protocol number
      cidr_blocks              = optional(list(string)) # (Optional) List of CIDR blocks. Cannot be specified with source_security_group_id or self.
      description              = optional(string)       # (Optional) Description of the rule.
      ipv6_cidr_blocks         = optional(list(string)) # (Optional) List of IPv6 CIDR blocks. Cannot be specified with source_security_group_id or self.
      prefix_list_ids          = optional(list(string)) # (Optional) List of Prefix List IDs.
      self                     = optional(bool)         # (Optional) Whether the security group itself will be added as a source to this ingress rule. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or source_security_group_id.
      source_security_group_id = optional(string)       # (Optional) Security group id to allow access to/from, depending on the type. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or self.
    })))
    tags = optional(map(string)) # (Optional) Additional key-value mapping of tags for the IAM role. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level.
  })
  validation {
    condition     = var.instance_security_group.create == false || can(regex("^sgp-[0-9]{4}-[dtaps]{1}-[0-9A-Za-z_-]+$", var.instance_security_group.name)) || can(regex("^sgp-[0-9]{4}-[dtaps]{1}-[0-9A-Za-z_-]+$", var.instance_security_group.name_prefix))
    error_message = "The `instance_security_group.name` or `instance_security_group.name_prefix` must follow the naming convention (sgp-1234-d-ec2-access) described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention#Security-Groups)."
  }
  validation {
    condition     = var.instance_security_group.create == false || var.instance_security_group.name != var.instance_security_group.name_prefix
    error_message = "Either `instance_security_group.name` or `instance_security_group.name_prefix` must be set."
  }
  validation {
    condition = !(length(var.instance_security_group.name != null ? var.instance_security_group.name : "") > 0 &&
    length(var.instance_security_group.name_prefix != null ? var.instance_security_group.name_prefix : "") > 0)
    error_message = "Both `instance_security_group.name` and `instance_security_group.name_prefix` cannot be set at the same time."
  }
  validation {
    condition = length([
      for rule in concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []) : true
      if rule.protocol == null || can(regex("^(icmp|icmpv6|tcp|udp|all|[0-9]+)$", rule.protocol))
    ]) == length(concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []))
    error_message = "The `instance_security_group.ingress_rules.*.protocol` and `instance_security_group.egress_rules.*.protocol` must be a valid protocol icmp, icmpv6, tcp, udp, all or the protocol number."
  }
  validation {
    condition = length([
      for rule in concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []) : true
      if rule.cidr_blocks == null || (rule.source_security_group_id == null && (rule.self == null || rule.self == false))
    ]) == length(concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []))
    error_message = "The `instance_security_group.ingress_rules.*.cidr_blocks` and `instance_security_group.egress_rules.*.cidr_blocks` cannot be specified with `source_security_group_id` or `self`."
  }
  validation {
    condition = length([
      for rule in concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []) : true
      if rule.ipv6_cidr_blocks == null || (rule.source_security_group_id == null && (rule.self == null || rule.self == false))
    ]) == length(concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []))
    error_message = "The `instance_security_group.ingress_rules.*.ipv6_cidr_blocks` and `instance_security_group.egress_rules.*.ipv6_cidr_blocks` cannot be specified with `source_security_group_id` or `self`."
  }
  validation {
    condition = length([
      for rule in concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []) : true
      if(rule.self == null || rule.self == false) || (rule.cidr_blocks == null && rule.ipv6_cidr_blocks == null && rule.source_security_group_id == null)
    ]) == length(concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []))
    error_message = "The `instance_security_group.ingress_rules.*.self` and `instance_security_group.egress_rules.*.self` cannot be specified with `cidr_blocks`, `ipv6_cidr_blocks`, or `source_security_group_id`."
  }
  validation {
    condition = length([
      for rule in concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []) : true
      if rule.source_security_group_id == null || (rule.cidr_blocks == null && rule.ipv6_cidr_blocks == null && (rule.self == null || rule.self == false))
    ]) == length(concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []))
    error_message = "The `instance_security_group.ingress_rules.*.source_security_group_id` and `instance_security_group.egress_rules.*.source_security_group_id` cannot be specified with cidr_blocks, ipv6_cidr_blocks, or self."
  }
  validation {
    condition = length([
      for rule in concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []) : true
      if rule.source_security_group_id == null || can(regex("^sg-[a-z0-9-]+$", rule.source_security_group_id))
    ]) == length(concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []))
    error_message = "The `instance_security_group.ingress_rules.*.source_security_group_id` and `instance_security_group.egress_rules.*.source_security_group_id` must be a valid AWS Security Group ID `sg-123456890`."
  }
  validation {
    condition = length([
      for rule in concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []) : true
      if anytrue([rule.cidr_blocks != null, rule.ipv6_cidr_blocks != null, rule.source_security_group_id != null, length(coalesce(rule.prefix_list_ids, [])) > 0, rule.self != null, rule.self == false])
    ]) == length(concat(var.instance_security_group.ingress_rules != null ? var.instance_security_group.ingress_rules : [], var.instance_security_group.egress_rules != null ? var.instance_security_group.egress_rules : []))
    error_message = "One of the following must be set cidr_blocks, ipv6_cidr_blocks, prefix_list_ids, self, or source_security_group_id in `instance_security_group.ingress_rules.*` and `instance_security_group.egress_rules.*`."
  }
  default = {}
}

variable "default_instance_security_group_rules" {
  description = "(Optional) A list of default Security Group Ingress and Egress rules."
  type = object({
    ingress_rules = list(object({
      port        = string                 # (Required) port (or ICMP type number if protocol is "icmp" or "icmpv6").
      cidr_blocks = optional(list(string)) # (Optional) List of CIDR blocks. Cannot be specified with source_security_group_id or self.
      description = optional(string)       # (Optional) Description of the rule.
    }))
    egress_rules = list(object({
      port        = string                 # (Required) port (or ICMP type number if protocol is "icmp" or "icmpv6").
      cidr_blocks = optional(list(string)) # (Optional) List of CIDR blocks. Cannot be specified with source_security_group_id or self.
      description = optional(string)       # (Optional) Description of the rule.
    }))
  })
  default = {
    ingress_rules = []
    egress_rules = [
      {
        port        = "80"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow Access to HTTP"
      },
      {
        port        = "443"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow Access to HTTPS"
      }
    ]
  }
}

# IAM Role
# https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204405770/OPA+Rules+0200-0399#OPA0200
variable "iam_role" {
  description = "(Optional) IAM role that will be attached to the AWS Instance."
  type = object({
    name                  = optional(string)       # (Required, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information. Follow the naming convention described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention#IAM-Roles-%26-Policies)
    name_prefix           = optional(string)       # (Optional, Forces new resource) Creates a unique friendly name beginning with the specified prefix. Conflicts with name.
    path                  = optional(string)       # (Optional) Path to the role. See IAM Identifiers for more information.
    description           = optional(string)       # (Optional) Description of the role.
    permissions_boundary  = optional(string)       # (Optional) ARN of the policy that is used to set the permissions boundary for the role, defaults to arn:aws:iam::{{account_id}}:policy/workload-boundary. TODO: check if we should expose this?
    force_detach_policies = optional(bool)         # (Optional) Whether to force detaching any policies the role has before destroying it. Defaults to true.
    policy_arns           = optional(list(string)) # (Optional) A list IAM Policy ARN you want to add to the role.
    tags                  = optional(map(string))  # (Optional) Additional key-value mapping of tags for the IAM role. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level.
  })
  default = {}
  validation {
    condition     = var.iam_role.name == null || can(regex("^role-[0-9]{4}-[dtaps]{1}-[0-9A-Za-z_-]+$", var.iam_role.name))
    error_message = "The `iam_role.name` must follow the naming convention (role-1234-d-allow-s3-access) described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention#IAM-Roles-%26-Policies)."
  }
  validation {
    condition = length([
      for policy_arn in coalesce(var.iam_role.policy_arns, []) : true
      if can(regex("^arn:aws:iam::[[:digit:]]{12}:policy/[0-9A-Za-z_-]+$", policy_arn))
    ]) == length(coalesce(var.iam_role.policy_arns, []))
    error_message = "The `iam_role.policy_arns.*` Must be a valid AWS IAM Policy ARN, see [AWS Identifiers ARNs](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html#identifiers-arns)."
  }
}

variable "aws_managed_iam_policy_arns" {
  description = "(Optional) A list of AWS managed IAM Policy ARNs to attach to the IAM role."
  type        = list(string)
  default     = []
  validation {
    condition = length([
      for default_iam_policy_arn in var.aws_managed_iam_policy_arns : true
      if can(regex("^arn:aws:iam::aws:policy/[0-9A-Za-z_-]+$", default_iam_policy_arn))
    ]) == length(var.aws_managed_iam_policy_arns)
    error_message = "The `default_iam_policy_arns.*` Must be a valid AWS managed IAM Policy ARN, see [aws-managed-policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html#aws-managed-policies)."
  }
}
