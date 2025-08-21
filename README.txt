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



