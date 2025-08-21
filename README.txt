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
    eks.amazonaws.com/role-arn: arn:aws:iam::<PROD_ACCOUNT_ID>:role/<ROLE_NAME>


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
              value: "<STAGE_BUCKET>"
            - name: SRC_PREFIX
              value: "<STAGE_PREFIX>"        # pode ser vazio ""
            - name: DST_BUCKET
              value: "<PROD_BUCKET>"
            - name: DST_PREFIX
              value: "<PROD_PREFIX>"         # pode ser vazio ""
            - name: SRC_REGION
              value: "<STAGE_REGION>"
            - name: DST_REGION
              value: "<PROD_REGION>"
            # Defina estas se for KMS na prod:
            - name: DST_KMS_KEY_ID
              value: "<PROD_KMS_KEY_ARN_OR_ID>"
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
