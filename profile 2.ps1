# Procura qualquer execução por callback
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/unified_jobs/?unified_job_template=4373&launch_type=callback&order_by=-created" | jq '.count,.results[0]'
# Procura execuções por webhook
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/unified_jobs/?unified_job_template=4373&launch_type=webhook&order_by=-created" | jq '.count,.results[0]'
# Troque $JOB_ID por um dos IDs (ex: 1006577)
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/jobs/$JOB_ID/activity_stream/?order_by=-timestamp" | jq '.results[] | {timestamp,actor,operation}'


# Quem pode executar esse JT (users, teams, applications)
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/4373/access_list/?role_level=execute&page_size=200" | jq '.results[] | {type,username,name,summary_fields}'
# Tokens de usuários com acesso
curl -s -H "Authorization: Bearer $TOKEN" "$AWX_HOST/api/v2/users/?page_size=200" \
| jq -r '.results[].id' | while read uid; do
  curl -s -H "Authorization: Bearer $TOKEN" "$AWX_HOST/api/v2/users/$uid/tokens/?page_size=200" \
  | jq --arg uid "$uid" '.results[] | {user_id:$uid, id, application, scope, created, modified, summary_fields}'
done
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/applications/?organization=101&page_size=200" | jq '.results[] | {id,name,client_id,organization}'
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/tokens/?page_size=200" | jq '.results[] | {id,scope,application,created,modified,summary_fields}'

# Schedules do projeto
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/projects/3869/schedules/" | jq '.results[] | {id,name,enabled,rrule,next_run}'

# Inventory sources do inventário e seus schedules
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/inventories/2073/inventory_sources/" | jq '.results[] | {id,name,source,update_on_launch}'
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/schedules/?inventory_source=<ID_DO_SOURCE>&enabled=true" | jq '.results[] | {id,name,rrule,next_run}'
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/unified_jobs/?unified_job_template=4373&launch_type=workflow&order_by=-created" | jq '.count,.results[0]'


# Info do endpoint de callback
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/4373/callback/" | jq '.'
# Procure jobs do tipo callback
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/unified_jobs/?unified_job_template=4373&launch_type=callback&order_by=-created" | jq '.count'
