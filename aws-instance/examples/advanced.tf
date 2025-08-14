data "aws_subnet_ids" "subnet_ids" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

resource "random_shuffle" "aws_instance_subnet" {
  input        = data.aws_subnet_ids.subnet_ids.ids
  result_count = 1
}

# Get AMIs from Shared Data
# More details about all the AMIs available here: https://gitlab.core-services.leaseplan.systems/shared/terraform_modules/aws/aws-shared-data
data "aws_caller_identity" "current" {}

module "aws_shared_data_basic" {
  source              = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-shared-data.git?ref=tags/TAG_REV"
  environment         = "development"
  workload_number     = "0029"
  entity              = "LPDI"
  application         = "network-services"
  wbs                 = "LPD-EH"
  project             = "network-intelligence-platform"
  service             = "network-services"
  logging_bucket_name = format("s3-bucket-logging-%s", data.aws_caller_identity.current.account_id)
}

module "aws_instance_advanced" {
  source                      = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-instance.git?ref=tags/TAG_REV"
  name                        = "test"                                      # (Required) Name to be used on all resources as prefix
  ami                         = module.aws_shared_data_basic.ami_id.al.2.id # (Optional) AMI to use for the instance. Required unless `launch_template` is specified and the Launch Template specifies an AMI. If an AMI is specified in the Launch Template, setting `ami` will override the AMI specified in the Launch Template.
  associate_public_ip_address = false                                       # (Optional) Whether to associate a public IP address with an instance in a VPC.
  availability_zone           = "eu-west-1a"                                # (Optional) AZ to start the instance in.
  capacity_reservation_specification = {
    capacity_reservation_preference = "open"                                                                     # (Optional) Indicates the instance's Capacity Reservation preferences. Can be "open" or "none". (Default: "open").
    capacity_reservation_target = {                                                                              # (Optional) Information about the target Capacity Reservation. See [Capacity Reservation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#capacity-reservation-target) Target below for more details.
      capacity_reservation_id                 = "some-id"                                                        # (Optional) The ID of the Capacity Reservation in which to run the instance.
      capacity_reservation_resource_group_arn = "arn:aws:resource-groups:sa-east-1:123456789012:group/MyCRGroup" # (Optional) The ARN of the Capacity Reservation resource group in which to run the instance.
    }
  }
  cpu_core_count       = 1 # (Optional) Sets the number of CPU cores for an instance. This option is only supported on creation of instance type that support CPU Options [CPU Cores and Threads Per CPU Core Per Instance Type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-optimize-cpu.html#cpu-options-supported-instances-values), specifying this option for unsupported instance types will return an error from the EC2 API. **NOTE:** Changing `cpu_core_count` and/or `cpu_threads_per_core` will cause the resource to be destroyed and re-created.
  cpu_threads_per_core = 2 # (Optional - has no effect unless `cpu_core_count` is also set)  If set to to 1, hyperthreading is disabled on the launched instance. Defaults to 2 if not set. See [Optimizing CPU Options](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-optimize-cpu.html) for more information.
  credit_specification = {
    cpu_credits = "standard" # (Optional) Credit option for CPU usage. Valid values include standard or unlimited. T3 instances are launched as unlimited by default. T2 instances are launched as standard by default.
  }
  disable_api_stop        = false # (Optional) If true, enables [EC2 Instance Stop Protection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Stop_Start.html#Using_StopProtection).
  disable_api_termination = false # (Optional) If true, enables [EC2 Instance Termination Protection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingDisableAPITermination).
  ebs_block_devices = [
    {
      delete_on_termination = true                                                                          # (Optional) Whether the volume should be destroyed on instance termination. Defaults to true.
      device_name           = "xvdb"                                                                        # (Required) Name of the device to mount. E.g., /dev/sdh or xvdh.
      encrypted             = true                                                                          # (Optional) Enables [EBS encryption](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html) on the volume. Defaults to false. Cannot be used with snapshot_id. Must be configured to perform drift detection.
      iops                  = 100                                                                           # (Optional) Amount of provisioned [IOPS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-io-characteristics.html). Only valid for volume_type of io1, io2 or gp3.
      kms_key_id            = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab" # (Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. Must be configured to perform drift detection.
      #      snapshot_id           = "some-id"       # (Optional) Snapshot ID to mount.
      tags        = { "some-extra-ebs-tag" = "some-tag-value" } # (Optional) A map of tags to assign to the device.
      throughput  = 100                                         # (Optional) Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of gp3.
      volume_size = 100                                         # (Optional) Size of the volume in gibibytes (GiB).
      volume_type = "gp3"                                       # (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp2.
    }
  ]
  ebs_optimized = true # (Optional) If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. See the [EBS Optimized section](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSOptimized.html) of the AWS User Guide for more information.
  enclave_options = {
    enabled = false # (Optional) Whether Nitro Enclaves will be enabled on the instance. Defaults to false. For more information, see the documentation on [Nitro Enclaves](https://docs.aws.amazon.com/enclaves/latest/user/nitro-enclave.html).
  }
  ephemeral_block_devices = [
    {
      device_name  = "xvdc"       # The name of the block device to mount on the instance. E.g., /dev/sdh or xvdh.
      no_device    = true         # (Optional) Suppresses the specified device included in the AMI's block device mapping.
      virtual_name = "ephemeral0" # (Optional) [Instance Store Device Name](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html#InstanceStoreDeviceNames) (e.g., ephemeral0).
    }
  ]
  get_password_data                    = false                                # (Optional) If true, wait for password data to become available and retrieve it. Useful for getting the administrator password for instances running Microsoft Windows. The password data is exported to the `password_data` attribute. See [GetPasswordData](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_GetPasswordData.html) for more information.
  hibernation                          = false                                # (Optional) If true, the launched EC2 instance will support hibernation.
  host_id                              = "host"                               # (Optional) ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host.
  iam_instance_profile                 = "profile-name"                       # (Optional) IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. Ensure your credentials have the correct permission to assign the instance profile according to the [EC2 documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html#roles-usingrole-ec2instance-permissions), notably `iam:PassRole`.
  instance_initiated_shutdown_behavior = "stop"                               # (Optional) Shutdown behavior for the instance. Amazon defaults this to `stop` for EBS-backed instances and `terminate` for instance-store instances. Cannot be set on instance-store instances. See [Shutdown Behavior](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior) for more information.
  instance_type                        = "t3.small"                           # (Optional) The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance. See [allowed_instance_types](https://gitlab.core-services.leaseplan.systems/scp-management/scp-manager/-/blob/master/src/scp_manager/scp_defaults.py) in Landing Zone, by default the following instances are allowed: c5.*, c5a.*, c5ad.*, c5d.*, c6g.*, m5.*, m5a.*, m5ad.*, m5d.*, m5zn.*, m6g.*, r5.*, r5a.*, r5ad.*, r5b.*, r5d.*, r6g.*, t3.*, t3a.* and t4g.*.
  ipv6_address_count                   = 2                                    # (Optional) A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet.
  ipv6_addresses                       = ["FE80:CD00:0:CDE:1257:0:211E:729C"] # (Optional) Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface
  key_name                             = "id_rsa"                             # (Optional) Key name of the Key Pair to use for the instance; which can be managed using [the `aws_key_pair` resource](key_pair.html).
  launch_template = {
    id = "someid" # The ID of the launch template. Conflicts with name.
    #    name    = "somename"  # The name of the launch template. Conflicts with id.
    version = "$Latest" # Template version. Can be a specific version number, $Latest or $Default. The default value is $Default.
  }
  maintenance_options = {
    auto_recovery = "default" # (Optional) The automatic recovery behavior of the Instance. Can be "default" or "disabled". See Recover your instance for more details.
  }
  metadata_options = {
    http_endpoint               = "enabled" # (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled.
    http_put_response_hop_limit = 64        # (Optional) Desired HTTP PUT response hop limit for instance metadata requests. The larger the number, the further instance metadata requests can travel. Valid values are integer from 1 to 64. Defaults to 1.
    instance_metadata_tags      = "enabled" # (optional) Enables or disables access to instance tags from the instance metadata service. Valid values include enabled or disabled. Defaults to disabled.
  }
  monitoring = true # (Optional) If true, the launched EC2 instance will have detailed monitoring enabled. (Available since v0.6.0)
  network_interface = [
    {
      delete_on_termination = true     # (Optional) Whether or not to delete the network interface on instance termination. Defaults to false. Currently, the only valid value is false, as this is only supported when creating new network interfaces when launching an instance.
      device_index          = 1        # (Required) Integer index of the network interface attachment. Limited by instance type.
      network_card_index    = 0        # (Optional) Integer index of the network card. Limited by instance type. The default index is 0.
      network_interface_id  = "someid" # (Required) ID of the network interface to attach.
    }
  ]
  placement_group            = "some group" # (Optional) Placement Group to start the instance in.
  placement_partition_number = 1            # (Optional) The number of the partition the instance is in. Valid only if [the `aws_placement_group` resource's](placement_group.html) `strategy` argument is set to `'partition'`.
  private_dns_name_options = {
    enable_resource_name_dns_aaaa_record = false     # Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records.
    enable_resource_name_dns_a_record    = true      # Indicates whether to respond to DNS queries for instance hostnames with DNS A records.
    hostname_type                        = "ip-name" # The type of hostname for Amazon EC2 instances. For IPv4 only subnets, an instance DNS name must be based on the instance IPv4 address. For IPv6 native subnets, an instance DNS name must be based on the instance ID. For dual-stack subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: ip-name and resource-name.
  }
  private_ip = "10.10.10.10" # (Optional) Private IP address to associate with the instance in a VPC.
  root_block_device = {
    delete_on_termination = true                                                                          # (Optional) Whether the volume should be destroyed on instance termination. Defaults to true.
    encrypted             = true                                                                          # (Optional) Whether to enable volume encryption. Defaults to false. Must be configured to perform drift detection.
    iops                  = 1000                                                                          # (Optional) Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3.
    kms_key_id            = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab" # (Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. Must be configured to perform drift detection.
    tags                  = { Name = "ebs" }                                                              # (Optional) A map of tags to assign to the device.
    throughput            = 100                                                                           # (Optional) Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of gp3.
    volume_size           = 50                                                                            # (Optional) Size of the volume in gibibytes (GiB).
    volume_type           = "gp3"                                                                         # (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp2.
  }
  secondary_private_ips = ["10.10.10.11"]                              # (Optional) A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e., referenced in a `network_interface` block. Refer to the [Elastic network interfaces documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI) to see the maximum number of private IP addresses allowed per instance type.
  source_dest_check     = true                                         # (Optional) Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. Defaults true.
  subnet_id             = random_shuffle.aws_instance_subnet.result[0] # (Optional) VPC Subnet ID to launch in.
  iam_role = {
    name = "role-9274-t-access-to-bastion" # (Required, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information. Follow the naming convention described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention#IAM-Roles-%26-Policies)
  }
  instance_security_group = {                                         # (Optional) Default instance Security Group and Security Group Rules. The following egress are added as defaults, allow 53(DNS), 80(HTTP) and 443(HTTPS) to the internet(0.0.0.0/0).
    name_prefix = "sgp-9274-t-ec2"                                    # (Required, Forces new resource) Name of the security group. Follow the naming convention described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention#Security-Groups)
    description = "EC2 Security Group, allows access from ... to ..." # (Optional, Forces new resource) Security group description. Defaults to Managed by Terraform. Cannot be \"\". NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags.
    ingress_rules = [                                                 # Provides a list of egress security group rules, which can be added to the Security Group. Setting `protocol = \"all\"` or `protocol = -1` with `from_port` and `to_port` will result in the EC2 API creating a security group rule with all ports open. This API behavior cannot be controlled by Terraform and may generate warnings in the future.
      {
        from_port   = 80                                # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
        to_port     = 80                                # (Optional) Uses from_port if not defined. End port (or ICMP code if protocol is "icmp").
        protocol    = "tcp"                             # (Optional) Defaults to tcp. If not icmp, icmpv6, tcp, udp, or all use the protocol number
        cidr_blocks = ["10.10.10.10/32"]                # (Optional) List of CIDR blocks. Cannot be specified with source_security_group_id or self.
        description = "Allow http access from host ..." # (Optional) Description of the rule.
      },
      {
        from_port        = 443                         # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
        ipv6_cidr_blocks = ["2001:db8:3333:4444::/64"] # (Optional) List of IPv6 CIDR blocks. Cannot be specified with source_security_group_id or self.
      },
      {
        from_port       = 443               # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
        prefix_list_ids = ["pl-0123456789"] # (Optional) List of Prefix List IDs.
      },
      {
        from_port = 443  # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
        self      = true # (Optional) Whether the security group itself will be added as a source to this ingress rule. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or source_security_group_id.
      },
      {
        from_port                = 443            # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
        source_security_group_id = "sg-123456789" # (Optional) Security group id to allow access to/from, depending on the type. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or self.
      }
    ]
    egress_rules = [ # Provides a list of egress security group rules, which can be added to the Security Group. Setting `protocol = \"all\"` or `protocol = -1` with `from_port` and `to_port` will result in the EC2 API creating a security group rule with all ports open. This API behavior cannot be controlled by Terraform and may generate warnings in the future.
      {
        from_port   = 80                                      # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
        to_port     = 80                                      # (Optional) Uses from_port if not defined. End port (or ICMP code if protocol is "icmp").
        protocol    = "tcp"                                   # (Optional) Defaults to tcp. If not icmp, icmpv6, tcp, udp, or all use the protocol number
        cidr_blocks = ["0.0.0.0/0"]                           # (Optional) List of CIDR blocks. Cannot be specified with source_security_group_id or self.
        description = "Allow http access to the internet ..." # (Optional) Description of the rule.
      },
      {
        from_port        = 443                         # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
        ipv6_cidr_blocks = ["2001:db8:3333:4444::/64"] # (Optional) List of IPv6 CIDR blocks. Cannot be specified with source_security_group_id or self.
      },
      {
        from_port       = 443               # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
        prefix_list_ids = ["pl-0123456789"] # (Optional) List of Prefix List IDs.
      },
      {
        from_port = 443  # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
        self      = true # (Optional) Whether the security group itself will be added as a source to this ingress rule. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or source_security_group_id.
      },
      {
        from_port                = 443            # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
        source_security_group_id = "sg-123456789" # (Optional) Security group id to allow access to/from, depending on the type. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or self.
      },
    ]
  }
  tags = { # A map of tags to assign to the resource. Note that these tags apply to the instance and not block storage devices. If configured with a provider [`default_tags` configuration block](/docs/providers/aws/index.html#default_tags-configuration-block) present, tags with matching keys will overwrite those defined at the provider-level.
    #     DataDog Tags
    "leaseplan:datadog" = true   # See [OPA0407](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204340577/OPA+Rules+0400-0449#OPA0407)
    "env"               = "dev"  # See [OPA0408](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204340577/OPA+Rules+0400-0449#OPA0408)
    "service"           = "demo" # See [OPA0409](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204340577/OPA+Rules+0400-0449#OPA0409)
    #     EC2 Tags
    "leaseplan:patch:zone"   = "blue"           # See [OPA0300](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204405770/OPA+Rules+0200-0399#OPA0300)
    "leaseplan:patch:reboot" = true             # See [OPA0300](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204405770/OPA+Rules+0200-0399#OPA0300)
    "leaseplan:os:type"      = "linux"          # See [OPA0302](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204405770/OPA+Rules+0200-0399#OPA0302)
    "leaseplan:os:version"   = "amazon-linuxv2" # See [OPA0302](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204405770/OPA+Rules+0200-0399#OPA0302)
    "leaseplan:backup:tier"  = "non-prod"       # See [OPA0304](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/2204405770/OPA+Rules+0200-0399#OPA0304)
  }
  tenancy                     = "host"             # (Optional) Tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command.
  user_data                   = "yum update"       # (Optional) User data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see `user_data_base64` instead. Updates to this field will trigger a stop/start of the EC2 instance by default. If the `user_data_replace_on_change` is set then updates to this field will trigger a destroy and recreate.
  user_data_base64            = "eXVtIHVwZGF0ZQo=" # (Optional) Can be used instead of `user_data` to pass base64-encoded binary data directly. Use this instead of `user_data` whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption. Updates to this field will trigger a stop/start of the EC2 instance by default. If the `user_data_replace_on_change` is set then updates to this field will trigger a destroy and recreate.
  user_data_replace_on_change = true               # (Optional) When used in combination with `user_data` or `user_data_base64` will trigger a destroy and recreate when set to `true`. Defaults to `false` if not set.
  vpc_security_group_ids      = ["sg-123456890"]   # (Optional, VPC only) A list of security group IDs to associate with.

  additional_disks = [
    {
      device_name = "xvdb"
      encrypted   = true
      iops        = 3000
      kms_key_id  = module.aws_shared_data.kms_key.arn
      throughput  = 1000
      size        = 100
      type        = "gp3"
    },
    {
      device_name = "xvdc"
      encrypted   = true
      iops        = 2000
      kms_key_id  = module.aws_shared_data.kms_key.arn
      throughput  = 1000
      size        = 100
      type        = "gp3"
    }
  ]
}
