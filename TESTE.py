- name: Debug vault token retrieval
  debug:
    msg: "Token length: {{ artifactory_access_token | length }}"
  no_log: false  # Temporariamente para debug (remova depois)

- name: Test token validity
  uri:
    url: "{{ artifactory_url }}/api/system/ping"
    headers:
      Authorization: "Bearer {{ artifactory_access_token }}"
    method: GET
  register: ping_result

- name: Show ping result
  debug:
    var: ping_result.status



# Fazer login para obter token:

TOKEN="seu_token_aqui"
AWX_HOST="https://awx.core-services.leaseplan.systems"

# Testar se o token funciona
curl -H "Authorization: Bearer YOUR_TOKEN" \
     "https://leaseplan.jfrog.io/artifactory/api/system/ping"

# Listar conteúdo do repositório
curl -H "Authorization: Bearer YOUR_TOKEN" \
     "https://leaseplan.jfrog.io/artifactory/api/storage/art-0072-generic-virtual/"

# Tentar baixar o arquivo
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -o /tmp/test.rpm \
     "https://leaseplan.jfrog.io/artifactory/art-0072-generic-virtual/java-22-amazon-corretto-devel-22.0.2.9-1.x86_64.rpm"











# Schedules específicos do template:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/job_templates/4373/schedules/" | jq '.results[] | {id, name, enabled, rrule, dtstart, next_run}'

# Todos os schedules ativos:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/schedules/?enabled=true&unified_job_template=4373" | jq '.results[] | {id, name, rrule, next_run}'
# Últimos 20 jobs do template:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/job_templates/4373/jobs/?page_size=20&order_by=-created" | jq '.results[] | {id, created, created_by, status, launch_type, execution_node}'

# Jobs da última hora:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/jobs/?job_template=4373&created__gte=$(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%SZ')&page_size=50" | jq '.results[] | {id, created, created_by, launch_type}'

# Atividades recentes do template:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/activity_stream/?object1=job_template&object1_pk=4373&page_size=20" | jq '.results[] | {timestamp, operation, actor, changes}'

# Atividades de launch do template:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/activity_stream/?operation__icontains=launch&object1_pk=4373&page_size=20" | jq '.results[] | {timestamp, actor, operation, changes}'

# Verificar configuração de callback:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/job_templates/4373/" | jq '{allow_callbacks, host_config_key, callback_url}'

# Verificar jobs lançados via callback:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/jobs/?job_template=4373&launch_type=callback&page_size=20" | jq '.results[] | {id, created, created_by, launch_type, execution_node}'

# Jobs das últimas 24 horas com horários:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/jobs/?job_template=4373&created__gte=$(date -u -d '24 hours ago' '+%Y-%m-%dT%H:%M:%SZ')&page_size=100" | jq '.results[] | {created: .created, launch_type: .launch_type, created_by: .created_by}' | jq -s 'sort_by(.created)'

# Extrair apenas as horas para ver o padrão:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/jobs/?job_template=4373&created__gte=$(date -u -d '24 hours ago' '+%Y-%m-%dT%H:%M:%SZ')&page_size=100" | jq -r '.results[] | .created' | cut -d'T' -f2 | cut -d':' -f1-2 | sort | uniq -c

# Verificar se tem notifications configuradas:
curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/job_templates/4373/notification_templates_started/" | jq '.'

curl -s -H "Authorization: Bearer $TOKEN" \
     "$AWX_HOST/api/v2/job_templates/4373/notification_templates_success/" | jq '.'







curl -X POST "https://awx.core-services.leaseplan.systems/api/v2/tokens/" \
     -H "Content-Type: application/json" \
     -u "[USUARIO]:[SENHA]" \
     -d '{
       "description": "CLI Investigation Token", 
       "application": null,
       "scope": "read"
     }'


{
  "msg": "Could not find the requested service tomcat: host",
  "invocation": {
    "module_args": {
      "name": "tomcat",
      "state": "restarted",
      "daemon_reload": false,
      "daemon_reexec": false,
      "scope": "system",
      "no_block": false,
      "enabled": null,
      "force": null,
      "masked": null
    }
  },
  "_ansible_no_log": false,
  "changed": false
}
fatal: [ec2-0072-a-sae1-lpfat-lp]: FAILED! => {"changed": false, "msg": "Could not find the requested service tomcat: host"}
---
# this is the defaulf configuration for ansible to work with ssm.
ansible_user: 'ssm-user'
ansible_connection: aws_ssm
ansible_aws_ssm_region: sa-east-1 
ansible_ssm_retry: 8
ansible_aws_ssm_timeout: 360

# here some variables that are needed for the domain join and can be used for other purposes.
aws_region: sa-east-1
workload_name: 0072-wkl-lpbr-apps
project_name: lpfat
artifactory_token: "artifactory/token/art-0072-read-generic-local-default"
artifactory_url: "https://leaseplan.jfrog.io/artifactory"
wkl_virt_repo_name: "art-{{ workload_name.split(\"-\")[0] }}-generic-virtual"
artifactory_bearer_token: "{{ lookup('hashi_vault', 'secret=artifactory/token/art-{{ workload_name.split(\"-\")[0] }}-read-generic-local-default:access_token url={{ vault_url }}') }}"
vault_url: "https://vault.core-services.leaseplan.systems"
jfrog_installer: "/var/tmp/install-jfrog-cli.sh"
corretto_pkg: "java-22-amazon-corretto-devel-22.0.2.9-1.x86_64.rpm"
tomcat_version: "10.1.30"
tomcat_archive: "/opt/apache-tomcat-{{ tomcat_version }}.tar.gz"
wkl_prefix: "{{ workload_name.split('-')[0] }}"
artifactory_reader_user: "art-{{ wkl_prefix }}-read-generic-local-default"
artifactory_reader_token_path: "artifactory/token/{{ artifactory_reader_user }}"


- name: Debug Linux configuration - start
  debug:
    msg: "--------------- Linux configuration started ---------------"

- name: Upgrade all packages
  ansible.builtin.package:
    name: "*"
    state: latest

- name: Install sshpass
  ansible.builtin.package:
    name: 
      - sshpass
      - fontconfig
    state: present

- name: Change instance timezone
  ansible.builtin.command: timedatectl set-timezone America/Sao_Paulo
  become: true

- name: This command will install jfrog cli
  ansible.builtin.get_url:
    url: https://install-cli.jfrog.io
    dest: "{{ jfrog_installer }}"
    mode: '0755'

- name: Set vault token
  set_fact:
    artifactory_access_token: "{{ lookup('community.hashi_vault.hashi_vault', 'url=' ~ vault_url ~ ' secret=' ~ artifactory_reader_token_path ~ ':access_token') }}"

- name: Fetch OpenJDK Corretto 22 from jfrog
  ansible.builtin.get_url:
    url: "{{ artifactory_url }}/{{ wkl_virt_repo_name }}/{{ corretto_pkg }}"
    headers:
      Authorization: "Bearer {{ artifactory_access_token }}"
    dest: "/tmp/{{ corretto_pkg }}"
    validate_certs: true


- name: Install OpenJDK Corretto 22
  ansible.builtin.yum:
    name: "/tmp/{{ corretto_pkg }}"
    state: present
    disable_gpg_check: true
  become: true

- name: Fetch the Apache Tomcat installer
  ansible.builtin.get_url:
    url: "{{ artifactory_url }}/{{ wkl_virt_repo_name }}/apache-tomcat-{{ tomcat_version }}.tar.gz"
    headers:
      Authorization: "Bearer {{ artifactory_access_token }}"
    dest: "{{ tomcat_archive }}"
    validate_certs: true
  become: true

- name: Unzip Tomcat 10
  ansible.builtin.unarchive:
    src: "{{ tomcat_archive }}"
    dest: /opt
    remote_src: yes
  become: true

- name: Rename Tomcat folder
  shell: | 
   [ -d /opt/tomcat10 ] || mv /opt/apache-tomcat-{{ tomcat_version }} /opt/tomcat10
  become: true

- name: Create Tomcat user
  ansible.builtin.user:
    name: tomcat
    shell: /sbin/nologin
    create_home: false
    state: present

- name: Copy tomcat users file
  copy:
    src: ./files/tomcat-users.xml.j2
    dest: /opt/tomcat10/conf/tomcat-users.xml
    mode: 0755
    force: false
  become: true

- name: Install LPFat application fonts
  ansible.builtin.get_url:
    url: "{{ artifactory_url }}/{{ wkl_virt_repo_name }}/LPFat/lpfat_fonts.zip"
    headers:
      Authorization: "Bearer {{ artifactory_access_token }}"
    dest: "/tmp/lpfat_fonts.zip"
    validate_certs: true

- name: Create folder for the application fonts
  file:
    path: /opt/tomcat10/fonts/
    state: directory
  become: true

- name: Unzip fonts file
  unarchive:
    src: /tmp/lpfat_fonts.zip
    dest: /opt/tomcat10/fonts/
    remote_src: yes
  become: true

- name: Create symbolic links for the tomcat scripts
  shell: | 
    [ -L /bin/tomcatup ] || ln -s /opt/tomcat10/bin/startup.sh /bin/tomcatup ; [ -L /bin/tomcatdown ] || ln -s /opt/tomcat10/bin/shutdown.sh /bin/tomcatdown
  args:
    chdir: /opt/tomcat10
  become: true    

- name: Stop tomcat
  shell: | 
    tomcatdown
  become: true
  become_user: tomcat
  ignore_errors: true
  
- name: Cleanup the tomcat and the temp folders
  shell: |
    rm -rf /opt/tomcat10/webapps/*.war /opt/tomcat10/webapps/LpFat_* /tmp/*.war
  become: true


- name: Download war files from the vendor SFTP server
  shell: |
    url=$(aws secretsmanager get-secret-value --region sa-east-1 --secret-id {{ secret_id }} | jq -r '.SecretString' | jq -r '.url' )
    port=$(aws secretsmanager get-secret-value --region sa-east-1 --secret-id {{ secret_id }} | jq -r '.SecretString' | jq -r '.port' )
    username=$(aws secretsmanager get-secret-value --region sa-east-1 --secret-id {{ secret_id }} | jq -r '.SecretString' | jq -r '.username' )
    password=$(aws secretsmanager get-secret-value --region sa-east-1 --secret-id {{ secret_id }} | jq -r '.SecretString' | jq -r '.password' )
    SSHPASS=${password} sshpass -e sftp -o StrictHostKeyChecking=accept-new -P ${port} ${username}@${url} << ENDSFTP
    cd releases/{{ env_dir }}/
    get *.war
    quit
    ENDSFTP
  args:
    chdir: /tmp/
  failed_when: false  

- name: Copy downloaded war files to the tomcat folder, if the files are new
  shell: |
    cp -u /tmp/*.war /opt/tomcat10/webapps/
  become: true
  failed_when: false

- name: Set LpFat S3 environment variables
  lineinfile:
    path: "/etc/environment"
    state: present
    line: "STORAGE_AWSS3_USE_IAM=true"
  become: true

- name: Change tomcat folder ownership
  file:
    path: /opt/tomcat10
    state: directory
    recurse: yes
    owner: tomcat
    group: tomcat

- name: Start tomcat
  shell: | 
    /opt/tomcat10/bin/startup.sh
  become: true
  become_user: tomcat

- name: Create a shell script from the user-data.txt file
  shell: |
    cp /var/lib/cloud/instance/user-data.txt /tmp/user-data.sh && chmod +x /tmp/user-data.sh
  become: true

#- name: Create cron job for the AWX rerun
#  cron:
#    name: "Run the user-data script every hour"
#    weekday: "*"
#    minute: "30"
#    hour: "*"
#    job: "/tmp/user-data.sh > /dev/null"
#    state: present
#  become: true

- name: Copy LPFat scheduler script
  copy:
    src: ./files/lpfat_scheduler.sh
    dest: /tmp/lpfat_scheduler.sh
    mode: 0755
    force: false
  become: true

- name: Restart Tomcat
  ansible.builtin.service:
    name: tomcat
    state: restarted  

#- name: Create cron job for the LPFat application scheduler
#  cron:
#    name: "Run the LPFat scheduler script every minute"
#    weekday: "*"
#    minute: "1"
#    hour: "*"
#    job: "/tmp/lpfat_scheduler.sh > /tmp/lpfat_scheduler.log"
#    state: present
#  become: true
