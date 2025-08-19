upload failed: .\ to s3://s3-integration-test-d-596599667803-sa-east-1/eCrlv/registros/ Need to rewind the stream <botocore.httpchecksum.AwsChunkedWrapper object at 0x0000022785733A10>, but stream is not seekable
AM+guimg@LPBR-WDW8AWEF MINGW64 ~/Downloads/crlv/local-folder-path
$ aws cp ./* "s3://s3-integration-test-d-596599667803-sa-east-1/eCrlv/registros/"
bash: /c/Program Files/Amazon/AWSCLIV2/aws: Argument list too long



AM+guimg@LPBR-WDW8AWEF MINGW64 ~/code/workloads/chatbot (LPBRCM-3220-test-clone-mobile-app)
$ git log
commit d25dd0a927925a699256ce1902468ce53ae506d7 (HEAD -> LPBRCM-3220-test-clone-mobile-app, origin/LPBRCM-3220-test-clone-mobile-app)
Author: Gabriel.Guimaraes <gabriel.guimaraes-ext@leaseplan.com>
Date:   Tue Aug 19 14:30:49 2025 -0300

    feat: setup test clone pipeline

commit d193f090dcbcc4d7e206ba1168878a848a2b618b
Author: Gabriel.Guimaraes <gabriel.guimaraes-ext@leaseplan.com>
Date:   Tue Aug 19 14:25:34 2025 -0300

    feat: setup test clone pipeline

commit cdf195b604b42389caad70024331d350cdd73cac
Author: Gabriel.Guimaraes <gabriel.guimaraes-ext@leaseplan.com>
Date:   Tue Aug 19 14:22:25 2025 -0300

    feat: setup test clone pipeline

commit 7fe400d7013b3a6973240a7b1ff45570d0f996fe
Merge: 36d8926 2e2e78d
Author: mario volpe <mario.volpe@leaseplan.com>
Date:   Tue May 6 01:29:10 2025 +0000

    Merge branch 'revert-36d89269' into 'master'

    Revert "Merge branch 'feature/LPBRCM-2758' into 'master'"

    See merge request workloads/0072-wkl-lpbr-apps/chatbot!12

commit 2e2e78d86443bdac15c5d5439f316c2f32e7630f
Author: mario volpe <mario.volpe@leaseplan.com>
Date:   Tue May 6 01:29:10 2025 +0000

    Revert "Merge branch 'feature/LPBRCM-2758' into 'master'"

AM+guimg@LPBR-WDW8AWEF MINGW64 ~/code/workloads/chatbot (LPBRCM-3220-test-clone-mobile-app)
$ git revert 36d8926
error: commit 36d89269aa087417146dc70fe98b8eb34eca94c6 is a merge but no -m option was given.
fatal: revert failed


https://gitlab.core-services.leaseplan.systems/workloads/0072-wkl-lpbr-apps/chatbot
https://gitlab.core-services.leaseplan.systems/workloads/0072-wkl-lpbr-apps/mobile-app

# DB2 CREDENTIALS
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db2-chatbot
  namespace: chatbot
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: db2-chatbot
    creationPolicy: Owner
  data:
    - secretKey: db2-chatbot-username
      remoteRef:
        key: sct-d-sae1-eks-db2-crlv
        property: username
    - secretKey: db2-chatbot-password
      remoteRef:
        key: sct-d-sae1-eks-db2-crlv
        property: password
    - secretKey: db2-chatbot-library
      remoteRef:
        key: sct-d-sae1-eks-db2-crlv
        property: library

---
# SYDLEONE CREDENTIALS
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: sydleone-chatbot
  namespace: chatbot
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: sydleone-chatbot
    creationPolicy: Owner
  data:
    - secretKey: sydleone-chatbot-url
      remoteRef:
        key: sct-d-sae1-eks-sydleone-workflow
        property: url
    - secretKey: sydleone-chatbot-token
      remoteRef:
        key: sct-d-sae1-eks-sydleone-workflow
        property: token

---
# BLIP CREDENTIALS
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: blip-chatbot
  namespace: chatbot
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: blip-chatbot
    creationPolicy: Owner
  data:
    - secretKey: blip-chatbot-url
      remoteRef:
        key: sct-d-sae1-eks-blip-chatbot
        property: url
    - secretKey: blip-chatbot-username
      remoteRef:
        key: sct-d-sae1-eks-blip-chatbot
        property: username
    - secretKey: blip-chatbot-password
      remoteRef:
        key: sct-d-sae1-eks-blip-chatbot
        property: password
    - secretKey: blip-chatbot-key
      remoteRef:
        key: sct-d-sae1-eks-blip-chatbot
        property: key

---
# SUPPLIER CREDENTIALS
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: supplier-chatbot
  namespace: chatbot
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: supplier-chatbot
    creationPolicy: Owner
  data:
    - secretKey: supplier-chatbot-url
      remoteRef:
        key: sct-d-sae1-eks-supplier-portal
        property: url

---
# POSTGRES BOS CREDENTIALS
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: postgres-bos
  namespace: chatbot
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: postgres-bos
    creationPolicy: Owner
  data:
    - secretKey: postgres-bos-url
      remoteRef:
        key: sct-d-sae1-eks-postgres-bos
        property: url
    - secretKey: postgres-bos-port
      remoteRef:
        key: sct-d-sae1-eks-postgres-bos
        property: port
    - secretKey: postgres-bos-database
      remoteRef:
        key: sct-d-sae1-eks-postgres-bos
        property: database
    - secretKey: postgres-bos-username
      remoteRef:
        key: sct-d-sae1-eks-postgres-bos
        property: username
    - secretKey: postgres-bos-password
      remoteRef:
        key: sct-d-sae1-eks-postgres-bos
        property: password

---
# POSTGRES SERVICES CREDENTIALS
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: postgres-services
  namespace: chatbot
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: postgres-services
    creationPolicy: Owner
  data:
    - secretKey: postgres-services-url
      remoteRef:
        key: sct-d-sae1-eks-postgres-services
        property: url
    - secretKey: postgres-services-port
      remoteRef:
        key: sct-d-sae1-eks-postgres-services
        property: port
    - secretKey: postgres-services-database
      remoteRef:
        key: sct-d-sae1-eks-postgres-services
        property: database
    - secretKey: postgres-services-username
      remoteRef:
        key: sct-d-sae1-eks-postgres-services
        property: username
    - secretKey: postgres-services-password
      remoteRef:
        key: sct-d-sae1-eks-postgres-services
        property: password

---
# RMT(TICKETLOG) API CREDENTIALS
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: rmt-ticketlog-api
  namespace: chatbot
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: rmt-ticketlog-api
    creationPolicy: Owner
  data:
    - secretKey: rmt-ticketlog-api-url
      remoteRef:
        key: sct-d-sae1-eks-api-rmt-ticketlog
        property: url
    - secretKey: rmt-ticketlog-api-username
      remoteRef:
        key: sct-d-sae1-eks-api-rmt-ticketlog
        property: username
    - secretKey: rmt-ticketlog-api-password
      remoteRef:
        key: sct-d-sae1-eks-api-rmt-ticketlog
        property: password

---
# CHATBOT MOBILE API CREDENTIALS
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: api-mobile-app
  namespace: chatbot
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: api-mobile-app
    creationPolicy: Owner
  data:
    - secretKey: api-mobile-app-url
      remoteRef:
        key: sct-d-sae1-eks-api-mobile-app
        property: url
    - secretKey: api-mobile-app-user
      remoteRef:
        key: sct-d-sae1-eks-api-mobile-app
        property: user
    - secretKey: api-mobile-app-password
      remoteRef:
        key: sct-d-sae1-eks-api-mobile-app
        property: password

---
# CHATBOT MOBILE API CREDENTIALS
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: api-mobile-app
  namespace: chatbot
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: api-mobile-app
    creationPolicy: Owner
  data:
    - secretKey: api-mobile-app-url
      remoteRef:
        key: sct-d-sae1-eks-api-mobile-app
        property: url
    - secretKey: api-mobile-app-user
      remoteRef:
        key: sct-d-sae1-eks-api-mobile-app
        property: username
    - secretKey: api-mobile-app-password
      remoteRef:
        key: sct-d-sae1-eks-api-mobile-app
        property: password
