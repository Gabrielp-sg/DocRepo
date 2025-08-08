JT=4373
ADMIN_ROLE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/$JT/" \
| jq -r '.summary_fields.object_roles.admin_role.id')
echo "ADMIN_ROLE_ID=$ADMIN_ROLE_ID"

curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/roles/$ADMIN_ROLE_ID/teams/?page_size=200" \
| jq '.results[] | {id, name}'

TEAM_ID=<ID_DO_TIME>
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"id": '"$TEAM_ID"', "disassociate": true}' \
  "$AWX_HOST/api/v2/roles/$ADMIN_ROLE_ID/teams/"
# Pegar IDs dos outros papéis do JT
EXEC_ROLE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/$JT/" \
| jq -r '.summary_fields.object_roles.execute_role.id')

READ_ROLE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/$JT/" \
| jq -r '.summary_fields.object_roles.read_role.id')

# Ver times com Execute e Read
curl -s -H "Authorization: Bearer $TOKEN" "$AWX_HOST/api/v2/roles/$EXEC_ROLE_ID/teams/?page_size=200" \
| jq '.results[] | {id,name}'

curl -s -H "Authorization: Bearer $TOKEN" "$AWX_HOST/api/v2/roles/$READ_ROLE_ID/teams/?page_size=200" \
| jq '.results[] | {id,name}'

# (Se houver) desassociar também
TEAM_ID=<ID_DO_TIME>
for RID in "$EXEC_ROLE_ID" "$READ_ROLE_ID"; do
  curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    -d '{"id": '"$TEAM_ID"', "disassociate": true}' \
    "$AWX_HOST/api/v2/roles/$RID/teams/"
done

AUTOMATION_USER="0072-wkl-d-automation-user"
AUTOMATION_UID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/users/?username=$AUTOMATION_USER" \
| jq -r '.results[0].id')

# Ver times do usuário
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/users/$AUTOMATION_UID/teams/?page_size=200" \
| jq '.results[] | {id,name}'

# Remover do time
TEAM_ID=<ID_DO_TIME>
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"id": '"$AUTOMATION_UID"', "disassociate": true}' \
  "$AWX_HOST/api/v2/teams/$TEAM_ID/users/"

curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/$JT/access_list/?page_size=200" \
| jq '.results[] | {username, role: .summary_fields.role_name}'


curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/roles/$ADMIN_ROLE_ID/teams/?page_size=200" \
| jq '.results'








AUTOMATION_USER=0072-wkl-d-automation-user
AUTOMATION_UID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/users/?username=$AUTOMATION_USER" \
| jq -r '.results[0].id')
echo "$AUTOMATION_UID"

curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/users/$AUTOMATION_UID/tokens/?page_size=200&order_by=-modified" \
| jq '.results[] | {id, description, scope, created, modified, summary_fields}'


curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/tokens/?page_size=200&order_by=-modified" \
| jq '.results[] | select(.summary_fields.user.username=="'"$AUTOMATION_USER"'") \
     | {id, description, scope, created, modified, summary_fields}'

curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/applications/?page_size=200" \
| jq '.results[] | {id, name, client_type, authorization_grant_type, organization, summary_fields}'

JT=4373
EXEC_ROLE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/$JT/" | jq -r '.summary_fields.object_roles.execute_role.id')

# Times com Execute
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/roles/$EXEC_ROLE_ID/teams/?page_size=200" \
| jq '.results[] | {id,name}'

# Usuários com Execute (confirma se o automation-user aparece)
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/roles/$EXEC_ROLE_ID/users/?page_size=200" \
| jq '.results[] | {id, username, first_name, last_name}'

curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/activity_stream/?actor=$AUTOMATION_UID&operation=create&object1=job&order_by=-timestamp&page_size=50" \
| jq '.results[] | {timestamp, actor: .summary_fields.actor.username, operation, object1, changes:{id,name,job_template,extra_vars}}'


# Desassociar usuário do papel Execute no JT
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"id": '"$AUTOMATION_UID"', "disassociate": true}' \
  "$AWX_HOST/api/v2/roles/$EXEC_ROLE_ID/users/"

for TID in $(curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/users/$AUTOMATION_UID/tokens/?page_size=200" \
| jq -r '.results[].id'); do
  curl -s -X DELETE -H "Authorization: Bearer $TOKEN" "$AWX_HOST/api/v2/tokens/$TID/"
done

curl -s -X PATCH -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"is_active": false}' \
  "$AWX_HOST/api/v2/users/$AUTOMATION_UID/"


curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/$JT/jobs/?page_size=5&order_by=-created" \
| jq '.results[] | {id, created, launch_type, launched_by: .summary_fields.created_by?.username}'

