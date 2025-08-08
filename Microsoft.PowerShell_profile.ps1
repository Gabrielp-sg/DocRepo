
JT=4373

# Lista TODOS os roles ligados a esse JT
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/roles/?content_type=job_template&object_id=$JT&page_size=200" \
| jq '.results[] | {id, name, type, description}'


# Só o papel Admin do JT
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/roles/?content_type=job_template&object_id=$JT&type=admin" \
| jq '.results[] | {id, name, type}'

# Só o papel Execute do JT
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/roles/?content_type=job_template&object_id=$JT&type=execute" \
| jq '.results[] | {id, name, type}'


ROLE_ID=<ROLE_ID_DO_ADMIN>

# Usuários com Admin no JT
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/roles/$ROLE_ID/users/?page_size=200" \
| jq '.results[] | {id, username, email}'

# Times com Admin no JT (se houver)
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/roles/$ROLE_ID/teams/?page_size=200" \
| jq '.results[] | {id, name}'



USER_ID=<ID_DO_USUARIO>

curl -s -X POST -H "Authorization: Bearer $TOKEN_ADMIN" -H "Content-Type: application/json" \
  -d "{\"id\": $USER_ID, \"disassociate\": true}" \
  "$AWX_HOST/api/v2/roles/$ROLE_ID/users/"

TEAM_ID=<ID_DO_TIME>

curl -s -X POST -H "Authorization: Bearer $TOKEN_ADMIN" -H "Content-Type: application/json" \
  -d "{\"id\": $TEAM_ID, \"disassociate\": true}" \
  "$AWX_HOST/api/v2/roles/$ROLE_ID/teams/"


# Descobrir a org do JT (se você não souber o ID)
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/job_templates/$JT/" \
| jq '.organization'

ORG_ID=<ID_DA_ORG>

# Pegar o papel Admin da organização
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/roles/?content_type=organization&object_id=$ORG_ID&type=admin" \
| jq '.results[] | {id, name, type}'

ORG_ADMIN_ROLE_ID=<ID_RETORNADO>

# Listar quem é org admin
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/roles/$ORG_ADMIN_ROLE_ID/users/?page_size=200" \
| jq '.results[] | {id, username, email}'

# Remover o usuário desse papel
USER_ID=<ID_DO_USUARIO>
curl -s -X POST -H "Authorization: Bearer $TOKEN_ADMIN" -H "Content-Type: application/json" \
  -d "{\"id\": $USER_ID, \"disassociate\": true}" \
  "$AWX_HOST/api/v2/roles/$ORG_ADMIN_ROLE_ID/users/"


# Descobrir a org do JT (se você não souber o ID)
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/job_templates/$JT/" \
| jq '.organization'

ORG_ID=<ID_DA_ORG>

# Pegar o papel Admin da organização
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/roles/?content_type=organization&object_id=$ORG_ID&type=admin" \
| jq '.results[] | {id, name, type}'

ORG_ADMIN_ROLE_ID=<ID_RETORNADO>

# Listar quem é org admin
curl -s -H "Authorization: Bearer $TOKEN_ADMIN" \
  "$AWX_HOST/api/v2/roles/$ORG_ADMIN_ROLE_ID/users/?page_size=200" \
| jq '.results[] | {id, username, email}'

# Remover o usuário desse papel
USER_ID=<ID_DO_USUARIO>
curl -s -X POST -H "Authorization: Bearer $TOKEN_ADMIN" -H "Content-Type: application/json" \
  -d "{\"id\": $USER_ID, \"disassociate\": true}" \
  "$AWX_HOST/api/v2/roles/$ORG_ADMIN_ROLE_ID/users/"






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

