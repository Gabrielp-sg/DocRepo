$ curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/4373/jobs/?page_size=15&order_by=-created" \
| jq '.results[] | {id, created, launch_type, started, finished,
       launched_by: .summary_fields.created_by?.username,
       job_explanation, controller_node}'
{
  "id": 1006629,
  "created": "2025-08-08T18:30:15.130982Z",
  "launch_type": "manual",
  "started": "2025-08-08T18:30:49.936354Z",
  "finished": "2025-08-08T18:37:36.206867Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006577,
  "created": "2025-08-08T17:30:17.151497Z",
  "launch_type": "manual",
  "started": "2025-08-08T17:30:54.166942Z",
  "finished": "2025-08-08T17:37:49.589630Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006555,
  "created": "2025-08-08T17:10:35.648982Z",
  "launch_type": "manual",
  "started": "2025-08-08T17:10:55.344530Z",
  "finished": "2025-08-08T17:17:49.669378Z",
  "launched_by": "gabriel.guimaraes-ext@leaseplan.com",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006519,
  "created": "2025-08-08T16:30:13.672003Z",
  "launch_type": "manual",
  "started": "2025-08-08T16:30:49.796462Z",
  "finished": "2025-08-08T16:37:38.762024Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006468,
  "created": "2025-08-08T15:30:16.256747Z",
  "launch_type": "manual",
  "started": "2025-08-08T15:30:44.895337Z",
  "finished": "2025-08-08T15:37:33.482249Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006415,
  "created": "2025-08-08T14:30:14.767220Z",
  "launch_type": "manual",
  "started": "2025-08-08T14:30:52.217237Z",
  "finished": "2025-08-08T14:37:49.950746Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006358,
  "created": "2025-08-08T13:30:26.559608Z",
  "launch_type": "manual",
  "started": "2025-08-08T13:30:55.894197Z",
  "finished": "2025-08-08T13:37:59.462448Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006295,
  "created": "2025-08-08T12:30:15.742838Z",
  "launch_type": "manual",
  "started": "2025-08-08T12:30:57.355003Z",
  "finished": "2025-08-08T12:37:51.639359Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006223,
  "created": "2025-08-08T11:30:16.454950Z",
  "launch_type": "manual",
  "started": "2025-08-08T11:30:49.917373Z",
  "finished": "2025-08-08T11:37:53.733154Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006172,
  "created": "2025-08-08T10:30:16.279999Z",
  "launch_type": "manual",
  "started": "2025-08-08T10:30:51.989573Z",
  "finished": "2025-08-08T10:37:44.239192Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006120,
  "created": "2025-08-08T09:30:13.057753Z",
  "launch_type": "manual",
  "started": "2025-08-08T09:30:42.895915Z",
  "finished": "2025-08-08T09:37:30.576516Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006067,
  "created": "2025-08-08T08:30:17.195796Z",
  "launch_type": "manual",
  "started": "2025-08-08T08:30:45.647367Z",
  "finished": "2025-08-08T08:37:34.911126Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1006010,
  "created": "2025-08-08T07:30:13.083181Z",
  "launch_type": "manual",
  "started": "2025-08-08T07:31:10.547922Z",
  "finished": "2025-08-08T07:38:02.375605Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1005952,
  "created": "2025-08-08T06:30:14.718658Z",
  "launch_type": "manual",
  "started": "2025-08-08T06:30:41.582291Z",
  "finished": "2025-08-08T06:37:51.575881Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}
{
  "id": 1005892,
  "created": "2025-08-08T05:30:15.964070Z",
  "launch_type": "manual",
  "started": "2025-08-08T05:30:53.573619Z",
  "finished": "2025-08-08T05:37:46.554527Z",
  "launched_by": "0072-wkl-d-automation-user",
  "job_explanation": "",
  "controller_node": "awx-v2-7b4d87d6cb-9wqlw"
}

AM+guimg@LPBR-WDW8AWEF MINGW64 ~
$ JOB_ID=1006577

AM+guimg@LPBR-WDW8AWEF MINGW64 ~
$ curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/jobs/$JOB_ID/" \
| jq '{id, created, launch_type, summary_fields:{created_by, unified_job_template, organization}}'
{
  "id": 1006577,
  "created": "2025-08-08T17:30:17.151497Z",
  "launch_type": "manual",
  "summary_fields": {
    "created_by": null,
    "unified_job_template": 4373,
    "organization": 101
  }
}

AM+guimg@LPBR-WDW8AWEF MINGW64 ~
$ curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/jobs/$JOB_ID/activity_stream/?order_by=-timestamp" \
| jq '.results[] | {timestamp, actor: .summary_fields.actor?.username, operation, changes}'
{
  "timestamp": "2025-08-08T17:30:17.182133Z",
  "actor": "0072-wkl-d-automation-user",
  "operation": "create",
  "changes": {
    "name": "0072-wkl-d-lpbr-apps-lpfat-linux",
    "description": "0072-wkl-d-lpbr-apps-lpfat",
    "job_type": "run",
    "inventory": "0072-wkl-d-lpbr-apps-lpfat-2073",
    "project": "0072-wkl-lpbr-apps-lpfat-3869",
    "playbook": "callback.yml",
    "scm_branch": "master",
    "forks": 0,
    "limit": "",
    "verbosity": 3,
    "extra_vars": "{\"instance_id\": \"i-04b6025e279b53acd\", \"target\": \"ec2-0072-d-sae1-lpfat-lp\", \"tasks\": [\"install_lpfat_tools\"]}",
    "job_tags": "",
    "force_handlers": false,
    "skip_tags": "",
    "start_at_task": "",
    "timeout": 0,
    "use_fact_cache": false,
    "execution_environment": "LeasePlan LZ Default Execution Environment (ansible core v2.12)-1",
    "job_template": "0072-wkl-d-lpbr-apps-lpfat-linux-4373",
    "allow_simultaneous": false,
    "instance_group": null,
    "diff_mode": true,
    "job_slice_number": 0,
    "job_slice_count": 1,
    "webhook_service": "",
    "webhook_credential": null,
    "webhook_guid": "",
    "id": 1006577,
    "credentials": [
      "0072-d-aws-ssm (1568)",
      "0072-d-vault-token (1567)"
    ],
    "labels": []
  }
}

AM+guimg@LPBR-WDW8AWEF MINGW64 ~
$ JT=4373
EXEC_ROLE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/$JT/" \
| jq -r '.summary_fields.object_roles.execute_role.id')

AM+guimg@LPBR-WDW8AWEF MINGW64 ~
$ # Usuários com Execute
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/roles/$EXEC_ROLE_ID/users/?page_size=200" \
| jq '.results[] | {id, username, first_name, last_name, email}'

# Teams com Execute (se houver)
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/roles/$EXEC_ROLE_ID/teams/?page_size=200" \
| jq '.results[] | {id, name}'

# Todos tokens ordenados pelo "modified" (mais recentes primeiro)
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/tokens/?order_by=-modified&page_size=200" \
| jq '.results[] | {id, description, scope, created, modified,
                    user: .summary_fields.user?.username,
                    application: .summary_fields.application?.name}'
{
  "id": 23,
  "description": "CLI Investigation Token",
  "scope": "read",
  "created": "2025-08-08T18:00:24.167830Z",
  "modified": "2025-08-08T18:00:24.176551Z",
  "user": "0072-wkl-d-automation-user",
  "application": null
}
{
  "id": 22,
  "description": "CLI Investigation Token",
  "scope": "read",
  "created": "2025-08-08T18:00:08.895785Z",
  "modified": "2025-08-08T18:00:08.907318Z",
  "user": "0072-wkl-d-automation-user",
  "application": null
}

AM+guimg@LPBR-WDW8AWEF MINGW64 ~
$ SUSPECT_USER_ID=1089  # troque pelo ID do usuário suspeito
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/users/$SUSPECT_USER_ID/tokens/?page_size=200" \
| jq '.results[] | {id, description, scope, created, modified, application}'


# Activity stream do template (pode mostrar quem lançou)
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/job_templates/4373/activity_stream/?order_by=-timestamp&page_size=50" \
| jq '.results[] | {timestamp, actor: .summary_fields.actor?.username, operation, changes}'
jq: error (at <stdin>:0): Cannot iterate over null (null)
{
  "timestamp": "2025-08-08T17:37:38.715010Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "job_type": [
      "run",
      "check"
    ],
    "verbosity": [
      3,
      0
    ]
  }
}
{
  "timestamp": "2025-08-08T17:10:19.516706Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "job_type": [
      "check",
      "run"
    ]
  }
}
{
  "timestamp": "2025-08-08T15:46:12.457263Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "verbosity": [
      0,
      3
    ]
  }
}
{
  "timestamp": "2025-08-08T14:47:53.697333Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "job_type": [
      "run",
      "check"
    ]
  }
}
{
  "timestamp": "2025-08-07T13:55:09.196838Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "job_type": [
      "check",
      "run"
    ]
  }
}
{
  "timestamp": "2025-08-06T15:25:12.468234Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "scm_branch": [
      "LPBRCM-3193-setup-envs-dev-acc",
      "master"
    ]
  }
}
{
  "timestamp": "2025-08-06T14:05:50.632686Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "scm_branch": [
      "fix/fixing-playbook-target",
      "LPBRCM-3193-setup-envs-dev-acc"
    ]
  }
}
{
  "timestamp": "2025-08-05T19:57:14.873017Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "job_type": [
      "run",
      "check"
    ]
  }
}
{
  "timestamp": "2025-08-05T17:37:20.556655Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "scm_branch": [
      "master",
      "fix/fixing-playbook-target"
    ]
  }
}
{
  "timestamp": "2025-08-05T17:29:41.203377Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "ask_limit_on_launch": [
      true,
      false
    ]
  }
}
{
  "timestamp": "2025-08-05T17:26:54.450482Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "job_type": [
      "check",
      "run"
    ],
    "scm_branch": [
      "supressed",
      "master"
    ]
  }
}
{
  "timestamp": "2025-08-04T21:08:46.345240Z",
  "actor": "mario.volpe@leaseplan.com",
  "operation": "update",
  "changes": {
    "scm_branch": [
      "WLDOPT-2515-lpfat-development",
      "supressed"
    ]
  }
}
{
  "timestamp": "2025-08-04T13:43:06.118017Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "job_type": [
      "run",
      "check"
    ],
    "become_enabled": [
      true,
      false
    ]
  }
}
{
  "timestamp": "2025-08-04T13:41:39.209068Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "become_enabled": [
      false,
      true
    ]
  }
}
{
  "timestamp": "2025-08-04T13:18:50.768940Z",
  "actor": "gabriel.guimaraes-ext@leaseplan.com",
  "operation": "update",
  "changes": {
    "ask_limit_on_launch": [
      false,
      true
    ]
  }
}
{
  "timestamp": "2025-07-23T19:04:57.331370Z",
  "actor": "mario.volpe@leaseplan.com",
  "operation": "update",
  "changes": {
    "scm_branch": [
      "supressed",
      "WLDOPT-2515-lpfat-development"
    ]
  }
}
{
  "timestamp": "2025-07-23T18:44:32.852259Z",
  "actor": "mario.volpe@leaseplan.com",
  "operation": "update",
  "changes": {
    "scm_branch": [
      "WLDOPT-2515-lpfat-development",
      "supressed"
    ]
  }
}
{
  "timestamp": "2025-07-23T17:58:46.907399Z",
  "actor": "mario.volpe@leaseplan.com",
  "operation": "update",
  "changes": {
    "scm_branch": [
      "supressed",
      "WLDOPT-2515-lpfat-development"
    ]
  }
}
{
  "timestamp": "2025-07-23T17:43:09.151024Z",
  "actor": "mario.volpe@leaseplan.com",
  "operation": "update",
  "changes": {
    "scm_branch": [
      "WLDOPT-2515-lpfat-development",
      "supressed"
    ]
  }
}
{
  "timestamp": "2025-07-23T17:25:22.230522Z",
  "actor": "mario.volpe@leaseplan.com",
  "operation": "update",
  "changes": {
    "scm_branch": [
      "supressed",
      "WLDOPT-2515-lpfat-development"
    ]
  }
}
{
  "timestamp": "2025-07-23T15:10:14.547859Z",
  "actor": "mario.volpe@leaseplan.com",
  "operation": "update",
  "changes": {
    "scm_branch": [
      "WLDOPT-2515-lpfat-development",
      "supressed"
    ]
  }
}

AM+guimg@LPBR-WDW8AWEF MINGW64 ~
$ SUSPECT_USER_ID=23

AM+guimg@LPBR-WDW8AWEF MINGW64 ~
$ curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/users/$SUSPECT_USER_ID/tokens/?page_size=200" \
| jq '.results[] | {id, description, scope, created, modified, application}'
jq: error (at <stdin>:0): Cannot iterate over null (null)

AM+guimg@LPBR-WDW8AWEF MINGW64 ~
$ # Workflow gerando esse job?
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/unified_jobs/?unified_job_template=4373&launch_type=workflow&order_by=-created" \
| jq '.count, .results[0]'

# Dependency (ex.: job encadeado)?
curl -s -H "Authorization: Bearer $TOKEN" \
  "$AWX_HOST/api/v2/unified_jobs/?unified_job_template=4373&launch_type=dependency&order_by=-created" \
| jq '.count, .results[0]'
0
null
0
