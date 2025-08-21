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


# veja o SA no pod
kubectl -n data-transfer get pod -l job-name=s3-move-once -o jsonpath='{.items[0].spec.serviceAccountName}{"\n"}'

# confira as variáveis injetadas pelo webhook de IRSA
kubectl -n data-transfer exec -it deploy/NAOEXISTE -- env | egrep 'AWS_(ROLE_ARN|WEB_IDENTITY_TOKEN_FILE)'
# (rode no pod em execução; se o Job falhou, relance com backoffLimit=0 mesmo)


Iniciando sync s3-integration-a-596599667803-sa-east-1/eCrlv/registros -> s3-integration-test-d-596599667803-sa-east-1/eCrlv/registros
Cmd: aws s3 sync s3://s3-integration-a-596599667803-sa-east-1/eCrlv/registros s3://s3-integration-test-d-596599667803-sa-east-1/eCrlv/registros --only-show-errors --exact-timestamps --source-region sa-east-1 --region sa-east-1 --exclude "*.tmp"
fatal error: An error occurred (AccessDenied) when calling the AssumeRoleWithWebIdentity operation: Not authorized to perform sts:AssumeRoleWithWebIdentity
stream closed EOF for data-transfer/s3-move-once-qrpvl (mover)


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



