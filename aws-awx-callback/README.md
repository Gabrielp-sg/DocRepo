# AWS AWX CALLBACK

## AWS AWX CALLBACK Terraform Module

### Terraform providers used:
- [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest)

### Terraform resources used:
- [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

# Terraform Docs

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## How to use this module:

### aws awx callback basic module usage with the required input variables:
```terraform
module "aws_awx_callback_basic" {
  source          = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-awx-callback.git?ref=tags/TAG_REV"
  os_type         = "windows"
  template_id     = 1111
  workload_number = 9999
  environment_id  = "d"
}
```

### aws awx callback advanced module usage with all the optional input variables:
```terraform
module "aws_awx_callback_advanced" {
  source          = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-awx-callback.git?ref=tags/TAG_REV"
  os_type         = "al2"
  template_id     = 1111
  workload_type   = "svc"
  workload_number = 9999
  environment_id  = "d"
  extra_vars = {
    "tasks" = ["install_cloudwatch_linux"]
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <= 2.0.0 |

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment_id"></a> [environment\_id](#input\_environment\_id) | Single letter identifier of DTAP environment [d\|t\|a\|p] | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Operating system to render the template | `string` | n/a | yes |
| <a name="input_template_id"></a> [template\_id](#input\_template\_id) | AWX template ID | `number` | n/a | yes |
| <a name="input_workload_number"></a> [workload\_number](#input\_workload\_number) | Unique 4-digit unique number that identifies the unique-numbering-index for the associated workload account. | `string` | n/a | yes |
| <a name="input_extra_vars"></a> [extra\_vars](#input\_extra\_vars) | Extra vars to pass to AWX | `map(any)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | Pass Region then default value | `string` | `"eu-west-1"` | no |
| <a name="input_workload_type"></a> [workload\_type](#input\_workload\_type) | Workload type | `string` | `"wkl"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | Rendered user\_data in non Base64 cleartext |
| <a name="output_user_data_base64"></a> [user\_data\_base64](#output\_user\_data\_base64) | Rendered user\_data Base64 encoded |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# How To contribute

## Install dependencies

* [pre-commit](https://pre-commit.com)
* [pre-commit-hooks](https://github.com/pre-commit/pre-commit-hooks)
* [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform)
* [terraform-docs](https://github.com/terraform-docs/terraform-docs)
* [tflint](https://github.com/terraform-linters/tflint)

#### MacOS

```bash
brew install pre-commit terraform-docs tflint
```

#### Ubuntu

```bash
python3 -m pip install --upgrade pip
pip3 install --no-cache-dir pre-commit
curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz && rm terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
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
