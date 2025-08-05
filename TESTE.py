/bin/sh: tomcatdown: command not found

fatal: [ec2-0072-a-sae1-lpfat-lp]: FAILED! => {"changed": true, "cmd": "tomcatdown\n", "delta": "0:00:00.007329", "end": "2025-08-05 16:26:32.610426", "msg": "non-zero return code", "rc": 127, "start": "2025-08-05 16:26:32.603097", "stderr": "/bin/sh: tomcatdown: command not found", "stderr_lines": ["/bin/sh: tomcatdown: command not found"], "stdout": "", "stdout_lines": []}
...ignoring

---
# role locations can be defined here, note: always use version numbers! (tags)
- src: https://gitlab.core-services.leaseplan.systems/shared/ansible_roles/domain_join.git
  scm: git
  version: "2.0.0"


- name: Debug Linux configuration - start
  debug:
    msg: "--------------- Linux configuration started ---------------"

- name: Upgrade all packages
  yum:
    name: "*"
    state: latest
  ignore_errors: true
  become: true

- name: Install sshpass
  yum:
    name: 
      - sshpass
      - fontconfig
    state: present
  ignore_errors: true
  become: true

- name: Change instance timezone
  shell: |
    timedatectl set-timezone America/Sao_Paulo
  become: true


- name: This command will install jfrog cli
  shell: |
    curl -fL https://install-cli.jfrog.io | sh
  args:
    chdir: /var/tmp
  become: true
  become_user: root

- name: Fetch OpenJDK Corretto 22 from jfrog
  get_url:
    url: "{{ artifactory_url }}/{{ wkl_virt_repo_name }}/java-22-amazon-corretto-devel-22.0.2.9-1.x86_64.rpm"
    url_username: "art-{{ workload_name.split(\"-\")[0] }}-read-generic-local-default"
    url_password: "{{ lookup('hashi_vault', 'secret=artifactory/token/art-{{ workload_name.split(\"-\")[0] }}-read-generic-local-default:access_token url={{ vault_url }}') }}"
    dest: /tmp/java-22-amazon-corretto-devel-22.0.2.9-1.x86_64.rpm


- name: Install OpenJDK Corretto 22
  yum:
    name: /tmp/java-22-amazon-corretto-devel-22.0.2.9-1.x86_64.rpm
    state: present
    disable_gpg_check: true
  become: true

- name: Fetch the Apache Tomcat installer
  get_url:
    url: "{{ artifactory_url }}/{{ wkl_virt_repo_name }}/apache-tomcat-10.1.30.tar.gz"
    url_username: "art-{{ workload_name.split(\"-\")[0] }}-read-generic-local-default"
    url_password: "{{ lookup('hashi_vault', 'secret=artifactory/token/art-{{ workload_name.split(\"-\")[0] }}-read-generic-local-default:access_token url={{ vault_url }}') }}"
    dest: /opt/apache-tomcat-10.1.30.tar.gz
  become: true

- name: Unzip Tomcat 10
  unarchive:
    src: /opt/apache-tomcat-10.1.30.tar.gz
    dest: /opt
    remote_src: yes
  become: true

- name: Rename Tomcat folder
  shell: | 
   [ -d /opt/tomcat10 ] || mv /opt/apache-tomcat-10.1.30 /opt/tomcat10
  become: true

- name: Create Tomcat user
  user:
    name: tomcat
    shell: /bin/bash
    create_home: no
    state: present
  become: true

- name: Copy tomcat users file
  copy:
    src: ./files/tomcat-users.xml.j2
    dest: /opt/tomcat10/conf/tomcat-users.xml
    mode: 0755
    force: false
  become: true

- name: Install LPFat application fonts
  get_url:
    url: "{{ artifactory_url }}/{{ wkl_virt_repo_name }}/LPFat/lpfat_fonts.zip"
    url_username: "art-{{ workload_name.split(\"-\")[0] }}-read-generic-local-default"
    url_password: "{{ lookup('hashi_vault', 'secret=artifactory/token/art-{{ workload_name.split(\"-\")[0] }}-read-generic-local-default:access_token url={{ vault_url }}') }}"
    dest: /tmp/lpfat_fonts.zip

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
    cd releases/Desenvolvimento/
    get *.war
    quit
    ENDSFTP
  args:
    chdir: /tmp/

- name: Copy downloaded war files to the tomcat folder, if the files are new
  shell: |
    cp -u /tmp/*.war /opt/tomcat10/webapps/
  become: true

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
    tomcatup
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

#- name: Create cron job for the LPFat application scheduler
#  cron:
#    name: "Run the LPFat scheduler script every minute"
#    weekday: "*"
#    minute: "1"
#    hour: "*"
#    job: "/tmp/lpfat_scheduler.sh > /tmp/lpfat_scheduler.log"
#    state: present
#  become: true
