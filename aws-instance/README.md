# AWS Instance
> Create an AWS Instance with an IAM role and Security Group.

## AWS Instance Module

### Terraform providers used:
- [aws](https://registry.terraform.io/providers/hashicorp/aws)

### Terraform Resources used:
- [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
- [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)
- [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
- [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)

### Terraform Data used:
- [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)
- [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)
- [aws_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)
- [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc)


# Terraform Docs

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## How to use this module:

### Basic module usage:
```terraform
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

module "aws_instance_basic" {
  source        = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-instance.git?ref=tags/TAG_REV"
  name          = "test"                                       # (Required) Name to be used on all resources as prefix
  instance_type = "t3.small"                                   # (Optional) The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance. See [allowed_instance_types](https://gitlab.core-services.leaseplan.systems/scp-management/scp-manager/-/blob/master/src/scp_manager/scp_defaults.py) in Landing Zone, by default the following instances are allowed: c5.*, c5a.*, c5ad.*, c5d.*, c6g.*, m5.*, m5a.*, m5ad.*, m5d.*, m5zn.*, m6g.*, r5.*, r5a.*, r5ad.*, r5b.*, r5d.*, r6g.*, t3.*, t3a.* and t4g.*.
  ami           = module.aws_shared_data_basic.ami_id.al.2.id  # (Optional) AMI to use for the instance. Required unless `launch_template` is specified and the Launch Template specifies an AMI. If an AMI is specified in the Launch Template, setting `ami` will override the AMI specified in the Launch Template.
  subnet_id     = random_shuffle.aws_instance_subnet.result[0] # (Optional) VPC Subnet ID to launch in.
  root_block_device = {
    delete_on_termination = true # (Optional) Whether the volume should be destroyed on instance termination. Defaults to true.
    encrypted             = true # (Optional) Enables [EBS encryption](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html) on the volume. Defaults to false. Cannot be used with snapshot_id. Must be configured to perform drift detection.
  }
  iam_role = {
    name = "role-9274-t-access-to-bastion" # (Required, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information. Follow the naming convention described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention#IAM-Roles-%26-Policies)
  }
  instance_security_group = {
    name_prefix = "sgp-9274-t-ec2" # (Required, Forces new resource) Name of the security group. Follow the naming convention described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention#Security-Groups)
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
  }                                             # A map of tags to assign to the resource. Note that these tags apply to the instance and not block storage devices. If configured with a provider [`default_tags` configuration block](/docs/providers/aws/index.html#default_tags-configuration-block) present, tags with matching keys will overwrite those defined at the provider-level.
}
```

### Advanced module usage:
```terraform
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |



## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.additional_disks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_iam_instance_profile.iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.default_egress_security_group_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.default_ingress_security_group_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_security_group_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_security_group_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_volume_attachment.additional_disks_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_caller_identity.caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_security_group.fmm_base_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) Name to be used on all resources as prefix | `string` | n/a | yes |
| <a name="input_additional_disks"></a> [additional\_disks](#input\_additional\_disks) | (Optional) One or more disks configuration blocks. | <pre>list(object({<br>    device_name = string                # (Required) Name of the device to mount. E.g., /dev/sdh or xvdh.<br>    encrypted   = optional(bool)        # (Optional) Enables [EBS encryption](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html) on the volume. Defaults to false. Cannot be used with snapshot_id. Must be configured to perform drift detection. # TODO: if we should not be supporting snapshot_id encrypted should be hardcoded to true (do not expose it to the module users).<br>    iops        = optional(number)      # (Optional) Amount of provisioned [IOPS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-io-characteristics.html). Only valid for volume_type of io1, io2 or gp3.<br>    kms_key_id  = optional(string)      # (Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. Must be configured to perform drift detection.<br>    snapshot_id = optional(string)      # (Optional) Snapshot ID to mount. # TODO: check if we should be supporting snapshot_id, is this allowed?<br>    throughput  = optional(number)      # (Optional) Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of gp3.<br>    size        = optional(number)      # (Optional) Size of the volume in gibibytes (GiB).<br>    type        = optional(string)      # (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp2.<br>    tags        = optional(map(string)) # (Optional) A map of tags to assign to the device.<br>  }))</pre> | `[]` | no |
| <a name="input_ami"></a> [ami](#input\_ami) | (Optional) AMI to use for the instance. Required unless `launch_template` is specified and the Launch Template specifies an AMI. If an AMI is specified in the Launch Template, setting `ami` will override the AMI specified in the Launch Template. | `string` | `null` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | (Optional) AZ to start the instance in. | `string` | `null` | no |
| <a name="input_aws_managed_iam_policy_arns"></a> [aws\_managed\_iam\_policy\_arns](#input\_aws\_managed\_iam\_policy\_arns) | (Optional) A list of AWS managed IAM Policy ARNs to attach to the IAM role. | `list(string)` | `[]` | no |
| <a name="input_capacity_reservation_specification"></a> [capacity\_reservation\_specification](#input\_capacity\_reservation\_specification) | (Optional) Describes an instance's Capacity Reservation targeting option. See [Capacity Reservation Specification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#capacity-reservation-specification) below for more details. | <pre>object({<br>    capacity_reservation_preference = optional(string)           # (Optional) Indicates the instance's Capacity Reservation preferences. Can be "open" or "none". (Default: "open").<br>    capacity_reservation_target = optional(object({              # (Optional) Information about the target Capacity Reservation. See [Capacity Reservation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#capacity-reservation-target) Target below for more details.<br>      capacity_reservation_id                 = optional(string) # (Optional) The ID of the Capacity Reservation in which to run the instance.<br>      capacity_reservation_resource_group_arn = optional(string) # (Optional) The ARN of the Capacity Reservation resource group in which to run the instance.<br>    }))<br>  })</pre> | `{}` | no |
| <a name="input_cpu_core_count"></a> [cpu\_core\_count](#input\_cpu\_core\_count) | (Optional) Sets the number of CPU cores for an instance. This option is only supported on creation of instance type that support CPU Options [CPU Cores and Threads Per CPU Core Per Instance Type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-optimize-cpu.html#cpu-options-supported-instances-values), specifying this option for unsupported instance types will return an error from the EC2 API. **NOTE:** Changing `cpu_core_count` and/or `cpu_threads_per_core` will cause the resource to be destroyed and re-created. | `number` | `null` | no |
| <a name="input_cpu_threads_per_core"></a> [cpu\_threads\_per\_core](#input\_cpu\_threads\_per\_core) | (Optional - has no effect unless `cpu_core_count` is also set)  If set to to 1, hyperthreading is disabled on the launched instance. Defaults to 2 if not set. See [Optimizing CPU Options](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-optimize-cpu.html) for more information. | `number` | `null` | no |
| <a name="input_credit_specification"></a> [credit\_specification](#input\_credit\_specification) | (Optional) Configuration block for customizing the credit specification of the instance. See [Credit Specification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#credit-specification) below for more details. Terraform will only perform drift detection of its value when present in a configuration. Removing this configuration on existing instances will only stop managing it. It will not change the configuration back to the default for the instance type. | <pre>object({<br>    cpu_credits = optional(string) # (Optional) Credit option for CPU usage. Valid values include standard or unlimited. T3 instances are launched as unlimited by default. T2 instances are launched as standard by default.<br>  })</pre> | `{}` | no |
| <a name="input_default_instance_security_group_rules"></a> [default\_instance\_security\_group\_rules](#input\_default\_instance\_security\_group\_rules) | (Optional) A list of default Security Group Ingress and Egress rules. | <pre>object({<br>    ingress_rules = list(object({<br>      port        = string                 # (Required) port (or ICMP type number if protocol is "icmp" or "icmpv6").<br>      cidr_blocks = optional(list(string)) # (Optional) List of CIDR blocks. Cannot be specified with source_security_group_id or self.<br>      description = optional(string)       # (Optional) Description of the rule.<br>    }))<br>    egress_rules = list(object({<br>      port        = string                 # (Required) port (or ICMP type number if protocol is "icmp" or "icmpv6").<br>      cidr_blocks = optional(list(string)) # (Optional) List of CIDR blocks. Cannot be specified with source_security_group_id or self.<br>      description = optional(string)       # (Optional) Description of the rule.<br>    }))<br>  })</pre> | <pre>{<br>  "egress_rules": [<br>    {<br>      "cidr_blocks": [<br>        "0.0.0.0/0"<br>      ],<br>      "description": "Allow Access to HTTP",<br>      "port": "80"<br>    },<br>    {<br>      "cidr_blocks": [<br>        "0.0.0.0/0"<br>      ],<br>      "description": "Allow Access to HTTPS",<br>      "port": "443"<br>    }<br>  ],<br>  "ingress_rules": []<br>}</pre> | no |
| <a name="input_disable_api_stop"></a> [disable\_api\_stop](#input\_disable\_api\_stop) | (Optional) If true, enables [EC2 Instance Stop Protection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Stop_Start.html#Using_StopProtection). | `bool` | `null` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | (Optional) If true, enables [EC2 Instance Termination Protection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingDisableAPITermination). | `bool` | `null` | no |
| <a name="input_ebs_block_devices"></a> [ebs\_block\_devices](#input\_ebs\_block\_devices) | (Optional) One or more configuration blocks with additional EBS block devices to attach to the instance. Block device configurations only apply on resource creation, adding this block in an already existing instance, will trigger the resource recreation. See [Block Devices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#ebs-ephemeral-and-root-block-devices) below for details on attributes and drift detection. When accessing this as an attribute reference, it is a set of objects. | <pre>list(object({<br>    #    Each ebs_block_device block supports the following:<br>    delete_on_termination = optional(bool)        # (Optional) Whether the volume should be destroyed on instance termination. Defaults to true.<br>    device_name           = string                # (Required) Name of the device to mount. E.g., /dev/sdh or xvdh.<br>    encrypted             = optional(bool)        # (Optional) Enables [EBS encryption](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html) on the volume. Defaults to false. Cannot be used with snapshot_id. Must be configured to perform drift detection. # TODO: if we should not be supporting snapshot_id encrypted should be hardcoded to true (do not expose it to the module users).<br>    iops                  = optional(number)      # (Optional) Amount of provisioned [IOPS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-io-characteristics.html). Only valid for volume_type of io1, io2 or gp3.<br>    kms_key_id            = optional(string)      # (Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. Must be configured to perform drift detection.<br>    snapshot_id           = optional(string)      # (Optional) Snapshot ID to mount. # TODO: check if we should be supporting snapshot_id, is this allowed?<br>    tags                  = optional(map(string)) # (Optional) A map of tags to assign to the device.<br>    throughput            = optional(number)      # (Optional) Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of gp3.<br>    volume_size           = optional(number)      # (Optional) Size of the volume in gibibytes (GiB).<br>    volume_type           = optional(string)      # (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp2.<br>  }))</pre> | `[]` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | (Optional) If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. See the [EBS Optimized section](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSOptimized.html) of the AWS User Guide for more information. | `bool` | `null` | no |
| <a name="input_enable_ffm_base_security_group"></a> [enable\_ffm\_base\_security\_group](#input\_enable\_ffm\_base\_security\_group) | (Optional) Whether to enable the AWS Firewall Manager Security Group. | `bool` | `true` | no |
| <a name="input_enclave_options"></a> [enclave\_options](#input\_enclave\_options) | (Optional) Enable Nitro Enclaves on launched instances. See [Enclave Options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#enclave-options) below for more details. | <pre>object({<br>    # The enclave_options block supports the following:<br>    enabled = optional(bool) # (Optional) Whether Nitro Enclaves will be enabled on the instance. Defaults to false. For more information, see the documentation on [Nitro Enclaves](https://docs.aws.amazon.com/enclaves/latest/user/nitro-enclave.html).<br>  })</pre> | `{}` | no |
| <a name="input_ephemeral_block_devices"></a> [ephemeral\_block\_devices](#input\_ephemeral\_block\_devices) | (Optional) One or more configuration blocks to customize Ephemeral (also known as 'Instance Store') volumes on the instance. See [Block Devices](#ebs-ephemeral-and-root-block-devices) below for details. When accessing this as an attribute reference, it is a set of objects. | <pre>list(object({<br>    # Each ephemeral_block_device block supports the following:<br>    device_name  = string           #  The name of the block device to mount on the instance.<br>    no_device    = optional(bool)   #  (Optional) Suppresses the specified device included in the AMI's block device mapping.<br>    virtual_name = optional(string) #  (Optional) [Instance Store Device Name](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html#InstanceStoreDeviceNames) (e.g., ephemeral0).<br>  }))</pre> | `[]` | no |
| <a name="input_get_password_data"></a> [get\_password\_data](#input\_get\_password\_data) | (Optional) If true, wait for password data to become available and retrieve it. Useful for getting the administrator password for instances running Microsoft Windows. The password data is exported to the `password_data` attribute. See [GetPasswordData](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_GetPasswordData.html) for more information. | `bool` | `null` | no |
| <a name="input_hibernation"></a> [hibernation](#input\_hibernation) | (Optional) If true, the launched EC2 instance will support hibernation. | `bool` | `null` | no |
| <a name="input_host_id"></a> [host\_id](#input\_host\_id) | (Optional) ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host. | `string` | `null` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | (Optional) IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. Ensure your credentials have the correct permission to assign the instance profile according to the [EC2 documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html#roles-usingrole-ec2instance-permissions), notably `iam:PassRole`. | `string` | `null` | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | (Optional) IAM role that will be attached to the AWS Instance. | <pre>object({<br>    name                  = optional(string)       # (Required, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information. Follow the naming convention described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention#IAM-Roles-%26-Policies)<br>    name_prefix           = optional(string)       # (Optional, Forces new resource) Creates a unique friendly name beginning with the specified prefix. Conflicts with name.<br>    path                  = optional(string)       # (Optional) Path to the role. See IAM Identifiers for more information.<br>    description           = optional(string)       # (Optional) Description of the role.<br>    permissions_boundary  = optional(string)       # (Optional) ARN of the policy that is used to set the permissions boundary for the role, defaults to arn:aws:iam::{{account_id}}:policy/workload-boundary. TODO: check if we should expose this?<br>    force_detach_policies = optional(bool)         # (Optional) Whether to force detaching any policies the role has before destroying it. Defaults to true.<br>    policy_arns           = optional(list(string)) # (Optional) A list IAM Policy ARN you want to add to the role.<br>    tags                  = optional(map(string))  # (Optional) Additional key-value mapping of tags for the IAM role. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level.<br>  })</pre> | `{}` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | (Optional) Shutdown behavior for the instance. Amazon defaults this to `stop` for EBS-backed instances and `terminate` for instance-store instances. Cannot be set on instance-store instances. See [Shutdown Behavior](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior) for more information. | `string` | `null` | no |
| <a name="input_instance_security_group"></a> [instance\_security\_group](#input\_instance\_security\_group) | (Optional) Default instance Security Group and Security Group Rules. The following egress are added as defaults, allow 53(DNS), 80(HTTP) and 443(HTTPS) to the internet(0.0.0.0/0). | <pre>object({<br>    create      = optional(bool, true) # (Optional, default true) Create default security group.<br>    name        = optional(string)     # (Required, Forces new resource) Name of the security group. Conflicts with `name_prefix`. Follow the naming convention described [here](https://leaseplan-digital.atlassian.net/wiki/spaces/LA/pages/1434390016/Resource+Naming+Convention#Security-Groups)<br>    name_prefix = optional(string)     # (Optional, Forces new resource) Name prefix of the security group. Conflicts with `name`. Can help avoid the Security Group Deletion Problem by using it instead of name.<br>    description = optional(string)     # (Optional, Forces new resource) Security group description. Defaults to Managed by Terraform. Cannot be "". NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags.<br>    ingress_rules = optional(list(object({<br>      from_port                = string                 # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").<br>      to_port                  = optional(string)       # (Optional) Uses from_port if not defined. End port (or ICMP code if protocol is "icmp").<br>      protocol                 = optional(string)       # (Optional) Defaults to tcp. If not icmp, icmpv6, tcp, udp, or all use the protocol number<br>      cidr_blocks              = optional(list(string)) # (Optional) List of CIDR blocks. Cannot be specified with source_security_group_id or self.<br>      description              = optional(string)       # (Optional) Description of the rule.<br>      ipv6_cidr_blocks         = optional(list(string)) # (Optional) List of IPv6 CIDR blocks. Cannot be specified with source_security_group_id or self.<br>      prefix_list_ids          = optional(list(string)) # (Optional) List of Prefix List IDs.<br>      self                     = optional(bool)         # (Optional) Whether the security group itself will be added as a source to this ingress rule. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or source_security_group_id.<br>      source_security_group_id = optional(string)       # (Optional) Security group id to allow access to/from, depending on the type. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or self.<br>    })))<br>    egress_rules = optional(list(object({<br>      from_port                = string                 # (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").<br>      to_port                  = optional(string)       # (Optional) Uses from_port if not defined. End port (or ICMP code if protocol is "icmp").<br>      protocol                 = optional(string)       # (Optional) Defaults to tcp. If not icmp, icmpv6, tcp, udp, or all use the protocol number<br>      cidr_blocks              = optional(list(string)) # (Optional) List of CIDR blocks. Cannot be specified with source_security_group_id or self.<br>      description              = optional(string)       # (Optional) Description of the rule.<br>      ipv6_cidr_blocks         = optional(list(string)) # (Optional) List of IPv6 CIDR blocks. Cannot be specified with source_security_group_id or self.<br>      prefix_list_ids          = optional(list(string)) # (Optional) List of Prefix List IDs.<br>      self                     = optional(bool)         # (Optional) Whether the security group itself will be added as a source to this ingress rule. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or source_security_group_id.<br>      source_security_group_id = optional(string)       # (Optional) Security group id to allow access to/from, depending on the type. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or self.<br>    })))<br>    tags = optional(map(string)) # (Optional) Additional key-value mapping of tags for the IAM role. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level.<br>  })</pre> | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | (Optional) The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance. See [allowed\_instance\_types](https://gitlab.core-services.leaseplan.systems/scp-management/scp-manager/-/blob/master/src/scp_manager/scp_defaults.py) in Landing Zone, by default the following instances are allowed: c5.*, c5a.*, c5ad.*, c5d.*, c6g.*, m5.*, m5a.*, m5ad.*, m5d.*, m5zn.*, m6g.*, r5.*, r5a.*, r5ad.*, r5b.*, r5d.*, r6g.*, t3.*, t3a.* and t4g.*. | `string` | `null` | no |
| <a name="input_ipv6_address_count"></a> [ipv6\_address\_count](#input\_ipv6\_address\_count) | (Optional) A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet. | `number` | `null` | no |
| <a name="input_ipv6_addresses"></a> [ipv6\_addresses](#input\_ipv6\_addresses) | (Optional) Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface | `list(string)` | `[]` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | (Optional) Key name of the Key Pair to use for the instance; which can be managed using [the `aws_key_pair` resource](key\_pair.html). | `string` | `null` | no |
| <a name="input_launch_template"></a> [launch\_template](#input\_launch\_template) | (Optional) Specifies a Launch Template to configure the instance. Parameters configured on this resource will override the corresponding parameters in the Launch Template. See [Launch Template Specification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#launch-template-specification) below for more details. | <pre>object({<br>    # The launch_template block supports the following:<br>    id      = optional(string) # The ID of the launch template. Conflicts with name.<br>    name    = optional(string) # The name of the launch template. Conflicts with id.<br>    version = string           # Template version. Can be a specific version number, $Latest or $Default. The default value is $Default.<br>  })</pre> | <pre>{<br>  "id": null,<br>  "name": null,<br>  "version": null<br>}</pre> | no |
| <a name="input_maintenance_options"></a> [maintenance\_options](#input\_maintenance\_options) | (Optional) The maintenance and recovery options for the instance. See [Maintenance Options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#maintenance-options) below for more details. | <pre>object({<br>    #  The maintenance_options block supports the following:<br>    auto_recovery = optional(string) # (Optional) The automatic recovery behavior of the Instance. Can be "default" or "disabled". See Recover your instance for more details.<br>  })</pre> | `{}` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | (Optional) Customize the metadata options of the instance. See [Metadata Options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#metadata-options) below for more details. | <pre>object({<br>    # The metadata_options block supports the following:<br>    http_endpoint               = optional(string) # (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled.<br>    http_put_response_hop_limit = optional(number) # (Optional) Desired HTTP PUT response hop limit for instance metadata requests. The larger the number, the further instance metadata requests can travel. Valid values are integer from 1 to 64. Defaults to 1.<br>    http_tokens                 = optional(string) # (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to required.<br>    instance_metadata_tags      = optional(string) # (optional) Enables or disables access to instance tags from the instance metadata service. Valid values include enabled or disabled. Defaults to disabled.<br>  })</pre> | <pre>{<br>  "http_endpoint": "enabled",<br>  "http_tokens": "required"<br>}</pre> | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | (Optional) If true, the launched EC2 instance will have detailed monitoring enabled. (Available since v0.6.0) | `bool` | `null` | no |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | (Optional) Customize network interfaces to be attached at instance boot time. See [Network Interfaces](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#network-interfaces) below for more details. | <pre>list(object({<br>    # Each network_interface block supports the following:<br>    delete_on_termination = optional(bool)   # (Optional) Whether or not to delete the network interface on instance termination. Defaults to false. Currently, the only valid value is false, as this is only supported when creating new network interfaces when launching an instance.<br>    device_index          = number           # (Required) Integer index of the network interface attachment. Limited by instance type.<br>    network_card_index    = optional(number) # (Optional) Integer index of the network card. Limited by instance type. The default index is 0.<br>    network_interface_id  = string           # (Required) ID of the network interface to attach.<br>  }))</pre> | `[]` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | (Optional) Placement Group to start the instance in. | `string` | `null` | no |
| <a name="input_placement_partition_number"></a> [placement\_partition\_number](#input\_placement\_partition\_number) | (Optional) The number of the partition the instance is in. Valid only if [the `aws_placement_group` resource's](placement\_group.html) `strategy` argument is set to `'partition'`. | `number` | `null` | no |
| <a name="input_private_dns_name_options"></a> [private\_dns\_name\_options](#input\_private\_dns\_name\_options) | (Optional) The options for the instance hostname. The default values are inherited from the subnet. See [Private DNS Name Options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#private-dns-name-options) below for more details. | <pre>object({<br>    # The private_dns_name_options block supports the following:<br>    enable_resource_name_dns_aaaa_record = bool   # Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records.<br>    enable_resource_name_dns_a_record    = bool   # Indicates whether to respond to DNS queries for instance hostnames with DNS A records.<br>    hostname_type                        = string # The type of hostname for Amazon EC2 instances. For IPv4 only subnets, an instance DNS name must be based on the instance IPv4 address. For IPv6 native subnets, an instance DNS name must be based on the instance ID. For dual-stack subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: ip-name and resource-name.<br>  })</pre> | <pre>{<br>  "enable_resource_name_dns_a_record": null,<br>  "enable_resource_name_dns_aaaa_record": null,<br>  "hostname_type": null<br>}</pre> | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | (Optional) Private IP address to associate with the instance in a VPC. | `string` | `null` | no |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | (Optional) Configuration block to customize details about the root block device of the instance. See [Block Devices](#ebs-ephemeral-and-root-block-devices) below for details. When accessing this as an attribute reference, it is a list containing one object. | <pre>object({<br>    #  The root_block_device block supports the following:<br>    delete_on_termination = optional(bool)        # (Optional) Whether the volume should be destroyed on instance termination. Defaults to true.<br>    encrypted             = optional(bool)        # (Optional) Whether to enable volume encryption. Defaults to false. Must be configured to perform drift detection.<br>    iops                  = optional(string)      # (Optional) Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3.<br>    kms_key_id            = optional(string)      # (Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. Must be configured to perform drift detection.<br>    tags                  = optional(map(string)) # (Optional) A map of tags to assign to the device.<br>    throughput            = optional(string)      # (Optional) Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of gp3.<br>    volume_size           = optional(string)      # (Optional) Size of the volume in gibibytes (GiB).<br>    volume_type           = optional(string)      # (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp2.<br>  })</pre> | `{}` | no |
| <a name="input_secondary_private_ips"></a> [secondary\_private\_ips](#input\_secondary\_private\_ips) | (Optional) A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e., referenced in a `network_interface` block. Refer to the [Elastic network interfaces documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI) to see the maximum number of private IP addresses allowed per instance type. | `list(string)` | `[]` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | (Optional) Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. Defaults true. | `bool` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Optional) VPC Subnet ID to launch in. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources created by this module. If configured with a provider [`default_tags` configuration block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags) present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | (Optional) Tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command. | `string` | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | (Optional) User data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see `user_data_base64` instead. Updates to this field will trigger a stop/start of the EC2 instance by default. If the `user_data_replace_on_change` is set then updates to this field will trigger a destroy and recreate. | `string` | `null` | no |
| <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64) | (Optional) Can be used instead of `user_data` to pass base64-encoded binary data directly. Use this instead of `user_data` whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption. Updates to this field will trigger a stop/start of the EC2 instance by default. If the `user_data_replace_on_change` is set then updates to this field will trigger a destroy and recreate. | `string` | `null` | no |
| <a name="input_user_data_replace_on_change"></a> [user\_data\_replace\_on\_change](#input\_user\_data\_replace\_on\_change) | (Optional) When used in combination with `user_data` or `user_data_base64` will trigger a destroy and recreate when set to `true`. Defaults to `false` if not set. | `bool` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Optional) VPC ID used for the security group. | `string` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | (Optional, VPC only) A list of security group IDs to associate with the instance. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the instance. |
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | The availability zone of the instance. |
| <a name="output_aws_iam_role"></a> [aws\_iam\_role](#output\_aws\_iam\_role) | The whole resource object, see [aws\_iam\_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role#attributes-reference) for more information. |
| <a name="output_aws_instance"></a> [aws\_instance](#output\_aws\_instance) | The whole resource object, see [aws\_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#attributes-reference) for more information. |
| <a name="output_aws_security_group"></a> [aws\_security\_group](#output\_aws\_security\_group) | The whole resource object, see [aws\_security\_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#attributes-reference) for more information. |
| <a name="output_capacity_reservation_specification"></a> [capacity\_reservation\_specification](#output\_capacity\_reservation\_specification) | Capacity reservation specification of the instance. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the instance. |
| <a name="output_instance_state"></a> [instance\_state](#output\_instance\_state) | The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`. See [Instance Lifecycle](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-lifecycle.html) for more information. |
| <a name="output_outpost_arn"></a> [outpost\_arn](#output\_outpost\_arn) | The ARN of the Outpost the instance is assigned to. |
| <a name="output_password_data"></a> [password\_data](#output\_password\_data) | Base-64 encoded encrypted password data for the instance. Useful for getting the administrator password for instances running Microsoft Windows. This attribute is only exported if `get_password_data` is true. Note that this encrypted value will be stored in the state file, as with all exported attributes. See [GetPasswordData](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_GetPasswordData.html) for more information. |
| <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id) | The ID of the instance's primary network interface. |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC. |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The private IP address assigned to the instance. |
| <a name="output_public_dns"></a> [public\_dns](#output\_public\_dns) | The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC. |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The public IP address assigned to the instance, if applicable. **NOTE**: If you are using an [`aws_eip`](/docs/providers/aws/r/eip.html) with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Import

### Import is supported using the following syntax:

Instances can be imported using the `id`, e.g.,

```
$ terraform import module.aws_instance.instance i-12345678
```

# How To contribute

## Install dependencies

* [pre-commit](https://pre-commit.com)
* [pre-commit-hooks](https://github.com/pre-commit/pre-commit-hooks)
* [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform)
* [terraform-docs](https://github.com/terraform-docs/terraform-docs)
* [terrascan](https://github.com/tenable/terrascan)
* [tflint](https://github.com/terraform-linters/tflint)
* [tfsec](https://github.com/liamg/tfsec)

#### MacOS

```bash
brew install pre-commit terraform-docs tflint tfsec terrascan
```

#### Ubuntu

```bash
python3 -m pip install --upgrade pip
pip3 install --no-cache-dir pre-commit
curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz && rm terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E -m 1 "https://.+?tfsec-linux-amd64")" > tfsec && chmod +x tfsec && sudo mv tfsec /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E -m 1 "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && tar -xzf terrascan.tar.gz terrascan && rm terrascan.tar.gz && sudo mv terrascan /usr/bin/ && terrascan init
```

### Install the pre-commit hook globally

> Note: not needed if you use the Docker image

```bash
DIR=~/.git-template
git config --global init.templateDir ${DIR}
pre-commit init-templatedir -t pre-commit ${DIR}
```

### Run the pre-commit

Execute this command to run `pre-commit` on all files in the repository (not only changed files):

```bash
pre-commit run -a
```
