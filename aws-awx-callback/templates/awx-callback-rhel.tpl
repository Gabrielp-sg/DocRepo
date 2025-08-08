#!/bin/bash

secret_id=${secret_id}
job_id=${template_id}
awx_url=${awx_url}
extra_vars=${extra_vars}
region=${region}


pwd=$(/usr/local/bin/aws --region $region secretsmanager get-secret-value --secret-id awx/$secret_id --output text --query SecretString | jq -r ".password")
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)
instance_id=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
instance_name=$(/usr/local/bin/aws --region $region ec2 describe-tags --filters Name=resource-id,Values=$instance_id Name=key,Values=Name --query Tags[].Value --output text)
curl -u $secret_id:$pwd  -L -v --post301 \
        $awx_url/api/v2/job_templates/$job_id/launch \
        -H "Content-Type:application/json"  \
        -d '{"extra_vars" : { "instance_id":"'"$instance_id"'","target" : "'"$instance_name"'" %{if extra_vars != ""}, ${extra_vars}  %{endif} }}'
