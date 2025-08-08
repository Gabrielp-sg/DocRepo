# Descobrir o ID do usuário "automation"
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/users/?username=0072-wkl-d-automation-user" \
| jq '.results[] | {id, username}'

# Guarde em USER_ID=XXXX
USER_ID=XXXX

# Descobrir o ID do papel Execute do JT
JT=4373
EXEC_ROLE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/$JT/" \
| jq -r '.summary_fields.object_roles.execute_role.id')

# Tirar o Execute do usuário nesse JT
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "{\"id\": $USER_ID, \"disassociate\": true}" \
  "$AWX_HOST/api/v2/roles/$EXEC_ROLE_ID/users/"



  
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/roles/$EXEC_ROLE_ID/teams/?page_size=200" \
| jq '.results[] | {id, name}'

# Para cada TEAM_ID, desassociar:
TEAM_ID=YYYY
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "{\"id\": $TEAM_ID, \"disassociate\": true}" \
  "$AWX_HOST/api/v2/roles/$EXEC_ROLE_ID/teams/"
