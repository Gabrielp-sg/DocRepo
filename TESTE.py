# --- S3 bucket TEMPORÁRIA (não altera o módulo/bucket atual)
module "aws_s3_integration_test" {
  source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-s3-bucket.git?ref=v5.0.0"

  # => mesmo padrão de nome, só inserindo "-test-"
  name_prefix   = format("s3-integration-test-%s", module.shared_data.workload.environment_identifier)

  # deixe igual à principal para “ser igual”, mas com:
  versioning    = true
  force_destroy = true   # facilita destruir depois mesmo com objetos/versões

  lifecycle_rule = [{
    id     = "expire_old_versions"
    status = "Enabled"
    noncurrent_version_expiration = {
      noncurrent_days = 10
    }
  }]

  tags = local.tags
}

# --- Pastas apenas na bucket de TESTE
resource "aws_s3_object" "s3_structure_test" {
  for_each = toset(local.s3_folders)

  bucket       = module.aws_s3_integration_test.bucket_id
  key          = each.value
  content_type = "application/x-directory"

  # mantém o mesmo comportamento de tags que você já usa
  override_provider {
    default_tags { tags = {} }
  }

  depends_on = [module.aws_s3_integration_test]
}



#S3 resource
module "aws_s3_integration" {
  source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-s3-bucket.git?ref=v5.0.0"

  name_prefix   = format("s3-integration-%s", module.shared_data.workload.environment_identifier)
  versioning    = true
  force_destroy = false

  lifecycle_rule = [{
    id     = "expire_old_versions"
    status = "Enabled"
    noncurrent_version_expiration = {
      noncurrent_days = 10
    }
  }]
  tags = local.tags

}

#S3 folders
locals {
  s3_folders = [
    "eCrlv/registros/",
    "eMultas/eventos/",
    "eMultas/eventos/indicacao/",
    "Workflow/tra/",
    "TicketLog/Agreements/",
    "TicketLog/Invoice/",
  ]
}

resource "aws_s3_object" "s3_structure" {
  for_each = toset(local.s3_folders)

  bucket       = module.aws_s3_integration.bucket_id
  key          = each.value
  content_type = "application/x-directory"

  override_provider {
    default_tags {
      tags = {}
    }
  }

  depends_on = [
    module.aws_s3_integration
  ]
}

#IAM for S3
data "aws_iam_policy_document" "policy_eks_lpbr_access_s3_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:crlv:lpbr",
        "system:serviceaccount:fines:lpbr-s3",
        "system:serviceaccount:workflow:lpbr-s3",
        "system:serviceaccount:glue-etl:lpbr-s3",
        "system:serviceaccount:ticketlog:lpbr-s3"
      ]
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "policy_eks_lpbr_access_s3" {
  statement {
    sid    = "ObjectAccess"
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObjectVersion",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::s3-integration-*/*",
      "arn:aws:s3:::s3-integration-*",
      "arn:aws:s3:::s3-glue-etl-*/*",
      "arn:aws:s3:::s3-glue-etl-*",
    ]
  }
}

resource "aws_iam_policy" "policy_eks_lpbr_access_s3" {
  name        = format("policy-0072-%s-eks-lpbr-access-s3", module.shared_data.workload.environment_identifier)
  path        = "/"
  description = "Allow lpbr app to access S3 buckets."
  policy      = data.aws_iam_policy_document.policy_eks_lpbr_access_s3.json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "role_eks_lpbr_access_s3" {
  role       = aws_iam_role.role_eks_lpbr_access_s3.name
  policy_arn = aws_iam_policy.policy_eks_lpbr_access_s3.arn
}

resource "aws_iam_role" "role_eks_lpbr_access_s3" {
  name                 = format("role-0072-%s-eks-lpbr-access-s3", module.shared_data.workload.environment_identifier)
  permissions_boundary = local.workload_boundary_arn
  assume_role_policy   = data.aws_iam_policy_document.policy_eks_lpbr_access_s3_assume_role_policy.json
  tags                 = local.tags
}



code ~/.bashrc
# no ~/.bash_profile
[ -f ~/.bashrc ] && . ~/.bashrc


# --- Git completion ---
if [ -f /usr/share/git/completion/git-completion.bash ]; then
  . /usr/share/git/completion/git-completion.bash
elif [ -f /mingw64/share/git/completion/git-completion.bash ]; then
  . /mingw64/share/git/completion/git-completion.bash
fi

# (Opcional) prompt do Git com o nome do branch
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
  . /usr/share/git/completion/git-prompt.sh
elif [ -f /mingw64/share/git/completion/git-prompt.sh ]; then
  . /mingw64/share/git/completion/git-prompt.sh
fi
# Exemplo simples de prompt mostrando o branch:
# PS1='[\u@\h \W$(__git_ps1 " (%s)")]$ '


source ~/.bashrc

[ -f ~/.git-completion.bash ] && . ~/.git-completion.bash
