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

# IAM Policy atualizada para incluir acesso cross-account
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
      # Buckets na conta atual (596599667803)
      "arn:aws:s3:::s3-integration-*/*",
      "arn:aws:s3:::s3-integration-*",
      "arn:aws:s3:::s3-glue-etl-*/*",
      "arn:aws:s3:::s3-glue-etl-*",
      
      # Bucket na conta de stage (847447826148) - ADICIONAR ESSA LINHA
      "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1",
      "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1/*",
    ]
  }
}

# Variável para facilitar configuração de contas externas
variable "external_s3_buckets" {
  description = "Lista de buckets em outras contas AWS que precisam de acesso"
  type        = list(string)
  default     = [
    "s3-integration-a-847447826148-sa-east-1"  # Conta de stage
  ]
}

# Policy mais flexível usando variáveis
data "aws_iam_policy_document" "policy_eks_lpbr_access_s3_flexible" {
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

    resources = concat(
      # Buckets na conta atual
      [
        "arn:aws:s3:::s3-integration-*/*",
        "arn:aws:s3:::s3-integration-*",
        "arn:aws:s3:::s3-glue-etl-*/*",
        "arn:aws:s3:::s3-glue-etl-*",
      ],
      # Buckets em contas externas
      flatten([
        for bucket in var.external_s3_buckets : [
          "arn:aws:s3:::${bucket}",
          "arn:aws:s3:::${bucket}/*"
        ]
      ])
    )
  }
}

# =============================================================================
# PARTE 2: Bucket Policy para a conta de destino (847447826148)
# Esta configuração deve ser aplicada na conta de STAGE
# =============================================================================

# Provider para a conta de stage (se usando multi-account setup)
# provider "aws" {
#   alias  = "stage"
#   region = "sa-east-1"
#   assume_role {
#     role_arn = "arn:aws:iam::847447826148:role/OrganizationAccountAccessRole"
#   }
# }

# Bucket policy na conta de stage permitindo acesso da conta de prod
data "aws_iam_policy_document" "stage_bucket_cross_account_policy" {
  statement {
    sid    = "AllowCrossAccountAccess"
    effect = "Allow"
    
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::596599667803:role/role-0072-d-eks-lpbr-access-s3",
        # Adicione outras roles se necessário
      ]
    }
    
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    
    resources = [
      "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1",
      "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1/*"
    ]
  }
}

# Aplicar a bucket policy (descomente se tiver acesso à conta de stage)
# resource "aws_s3_bucket_policy" "stage_cross_account_policy" {
#   provider = aws.stage
#   bucket   = "s3-integration-a-847447826148-sa-east-1"
#   policy   = data.aws_iam_policy_document.stage_bucket_cross_account_policy.json
# }

# =============================================================================
# ALTERNATIVA: JSON da bucket policy para aplicar manualmente
# =============================================================================

# Você pode aplicar esta policy manualmente na conta de stage via AWS Console
# ou CLI se não tiver acesso via Terraform:

# aws s3api put-bucket-policy \
#   --bucket s3-integration-a-847447826148-sa-east-1 \
#   --policy '{
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Sid": "AllowCrossAccountAccess",
#         "Effect": "Allow",
#         "Principal": {
#           "AWS": "arn:aws:iam::596599667803:role/role-0072-d-eks-lpbr-access-s3"
#         },
#         "Action": [
#           "s3:ListBucket",
#           "s3:GetBucketLocation",
#           "s3:GetObject",
#           "s3:GetObjectAcl",
#           "s3:PutObject",
#           "s3:PutObjectAcl",
#           "s3:DeleteObject",
#           "s3:DeleteObjectVersion"
#         ],
#         "Resource": [
#           "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1",
#           "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1/*"
#         ]
#       }
#     ]
#   }'

# =============================================================================
# PASSOS PARA IMPLEMENTAR:
# =============================================================================

# 1. Atualize sua policy IAM atual no arquivo principal:
#    - Substitua o data source "policy_eks_lpbr_access_s3" pela versão atualizada acima
#    - Ou use a versão flexível com variáveis

# 2. Execute terraform plan/apply na conta atual (596599667803)

# 3. Configure a bucket policy na conta de stage (847447826148):
#    - Via Terraform (se tiver acesso multi-account)
#    - Via AWS CLI (comando acima)
#    - Via AWS Console

# 4. Teste o acesso executando o job novamente



# Modifique a policy existente para incluir acesso cross-account
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
      # Buckets na conta atual (dev - 596599667803)
      "arn:aws:s3:::s3-integration-*/*",
      "arn:aws:s3:::s3-integration-*",
      "arn:aws:s3:::s3-glue-etl-*/*",
      "arn:aws:s3:::s3-glue-etl-*",
      
      # Buckets na conta de staging (847447826148) - NOVO
      "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1",
      "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1/*",
    ]
  }

  # Adicione uma nova statement específica para cross-account se necessário
  statement {
    sid    = "CrossAccountS3Access"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetBucketLocation",
    ]
    
    resources = [
      "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1",
      "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1/*",
    ]
  }
}

# Opcional: Criar uma policy separada para cross-account
resource "aws_iam_policy" "policy_eks_lpbr_cross_account_s3" {
  name        = format("policy-0072-%s-eks-lpbr-cross-account-s3", module.shared_data.workload.environment_identifier)
  path        = "/"
  description = "Allow lpbr app to access S3 buckets in staging account."
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CrossAccountS3Access"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:GetBucketAcl"
        ]
        Resource = [
          "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1",
          "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1/*"
        ]
      }
    ]
  })
  
  tags = local.tags
}

# Anexar a policy cross-account à role existente
resource "aws_iam_role_policy_attachment" "role_eks_lpbr_cross_account_s3" {
  role       = aws_iam_role.role_eks_lpbr_access_s3.name
  policy_arn = aws_iam_policy.policy_eks_lpbr_cross_account_s3.arn
}




Iniciando sync s3-integration-a-847447826148-sa-east-1/eCrlv/registros -> s3-integration-test-d-596599667803-sa-east-1/eCrlv/registros
Cmd: aws s3 sync s3://s3-integration-a-847447826148-sa-east-1/eCrlv/registros s3://s3-integration-test-d-596599667803-sa-east-1/eCrlv/registros --only-show-errors --exact-timestamps --source-region sa-east-1 --region sa-east-1 --exclude "*.tmp"
fatal error: An error occurred (AccessDenied) when calling the ListObjectsV2 operation: User: arn:aws:sts::596599667803:assumed-role/role-0072-d-eks-lpbr-access-s3/botocore-session-1755804014 is not authorized to perform: s3:ListBucket on resource: "arn:aws:s3:::s3-integration-a-847447826148-sa-east-1" because no resource-based policy allows the s3:ListBucket action
stream closed EOF for data-transfer/s3-move-once-qpn42 (mover)


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
// To do: delete after usage
module "aws_s3_integration_test" {
  source = "git@gitlab.core-services.leaseplan.systems:shared/terraform_modules/aws/aws-s3-bucket.git?ref=v5.0.0"

  name_prefix   = format("s3-integration-test-%s", module.shared_data.workload.environment_identifier)

  versioning    = true
  force_destroy = true  

  lifecycle_rule = [{
    id     = "expire_old_versions"
    status = "Enabled"
    noncurrent_version_expiration = {
      noncurrent_days = 10
    }
  }]

  tags = local.tags
}

resource "aws_s3_object" "s3_structure_test" {
  for_each = toset(local.s3_folders)

  bucket       = module.aws_s3_integration_test.bucket_id
  key          = each.value
  content_type = "application/x-directory"
  override_provider {
    default_tags { tags = {} }
  }

  depends_on = [module.aws_s3_integration_test]
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
        "system:serviceaccount:data-transfer:s3-mover"
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


---
apiVersion: v1
kind: Namespace
metadata:
  name: data-transfer
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-mover
  namespace: data-transfer
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::596599667803:role/role-0072-d-eks-lpbr-access-s3
---
apiVersion: batch/v1
kind: Job
metadata:
  name: s3-move-once
  namespace: data-transfer
spec:
  backoffLimit: 0
  template:
    spec:
      serviceAccountName: s3-mover
      restartPolicy: Never
      containers:
        - name: mover
          image: public.ecr.aws/aws-cli/aws-cli:2.17.7
          env:
            - name: SRC_BUCKET
              value: "s3-integration-a-596599667803-sa-east-1"
            - name: SRC_PREFIX
              value: "eCrlv/registros"        # pode ser vazio ""s3://s3-integration-test-d-596599667803-sa-east-1/eCrlv/registros/
            - name: DST_BUCKET
              value: "s3-integration-test-d-596599667803-sa-east-1"
            - name: DST_PREFIX
              value: "eCrlv/registros"         # pode ser vazio ""
            - name: SRC_REGION
              value: "sa-east-1"
            - name: DST_REGION
              value: "sa-east-1"
            # # Defina estas se for KMS na prod:
            # - name: DST_KMS_KEY_ID
            #   value: "<PROD_KMS_KEY_ARN_OR_ID>"
            # (opcional) filtros:
            - name: EXTRA_FLAGS
              value: "--exclude \"*.tmp\""
          command: ["sh","-c"]
          args:
            - >
              set -euo pipefail;
              echo "Iniciando sync ${SRC_BUCKET}/${SRC_PREFIX} -> ${DST_BUCKET}/${DST_PREFIX}";
              BASE_CMD="aws s3 sync s3://${SRC_BUCKET}/${SRC_PREFIX} s3://${DST_BUCKET}/${DST_PREFIX}
              --only-show-errors --exact-timestamps --source-region ${SRC_REGION} --region ${DST_REGION}";
              if [ -n "${DST_KMS_KEY_ID:-}" ]; then
                BASE_CMD="$BASE_CMD --sse aws:kms --sse-kms-key-id ${DST_KMS_KEY_ID}";
              fi;
              if [ -n "${EXTRA_FLAGS:-}" ]; then
                BASE_CMD="$BASE_CMD ${EXTRA_FLAGS}";
              fi;
              echo "Cmd: $BASE_CMD";
              eval $BASE_CMD;
              echo "Concluído.";



