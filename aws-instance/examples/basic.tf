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
