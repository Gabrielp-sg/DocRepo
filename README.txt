---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: chatbot
  name: ingress-chatbot
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/wafv2-acl-arn: arn:aws:wafv2:sa-east-1:847447826148:regional/webacl/eks_apps_web_acl/af98e720-1ffc-4278-b64b-4b0ad059be01
    alb.ingress.kubernetes.io/load-balancer-attributes: routing.http.drop_invalid_header_fields.enabled=true,access_logs.s3.enabled=true,access_logs.s3.bucket=plt-elb-logs-596599667803-sa-east-1,access_logs.s3.prefix=alb,idle_timeout.timeout_seconds=180
    external-dns.alpha.kubernetes.io/hostname: chatbot.acc.lpbr.leaseplan.systems
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:sa-east-1:847447826148:certificate/b2dafce6-5230-44b7-a4c1-344ef528b1a9
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-FS-1-2-Res-2020-10
spec:
  ingressClassName: alb
  rules:
  - http:
      paths:
      - path: /product/chatbot/v1/consulta/
        pathType: Prefix
        backend:
          service:
            name: chatbot-consulta
            port:
              number: 8080
      - path: /product/chatbot/v1/agendamento/
        pathType: Prefix
        backend:
          service:
            name: chatbot-agendamento
            port:
              number: 8080
      - path: /product/chatbot/v1/atendimento/
        pathType: Prefix
        backend:
          service:
            name: chatbot-atendimento
            port:
              number: 8080
      - path: /product/chatbot/v1/atualiza/
        pathType: Prefix
        backend:
          service:
            name: chatbot-atualiza
            port:
              number: 8080
      - path: /product/chatbot/v1/pedido/
        pathType: Prefix
        backend:
          service:
            name: chatbot-pedido
            port:
              number: 8080
      - path: /product/chatbot/v2/consulta/
        pathType: Prefix
        backend:
          service:
            name: chatbot-consulta
            port:
              number: 8080    
      - path: /product/chatbot/v2/agendamento/
        pathType: Prefix
        backend:
          service:
            name: chatbot-agendamento
            port:
              number: 8080 
      - path: /product/chatbot/v2/atendimento/
        pathType: Prefix
        backend:
          service:
            name: chatbot-atendimento
            port:
              number: 8080 
      - path: /product/chatbot/v2/atualiza/
        pathType: Prefix
        backend:
          service:
            name: chatbot-atualiza
            port:
              number: 8080


curl --location 'https://*****/product/chatbot/v2/agendamento/criar' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer ******g' \
--data-raw '{
    "placa": "FNI8B55",
    "km": 40000,
    "descricaoServico": "teste de cria agendamento MV1",
    "tipoServico": "revisao",
    "fornecedor": 10549,
    "dataAgendamento": [
        {
            "data": "2025-08-29T09:00:00.000Z"
        },
        {
            "data": "2025-08-29T09:30:00.000Z"
        }
    ],
    "solicitante": {
        "nome": "Mario Volpe",
        "celular": "11987654321",
        "email": "*****@l***"
    },
    "anomalia": {
        "acessorio": false,
        "corretiva": false,
        "pneus": false,
        "outros": false
    },
    "canal": "WHATS"
}'
