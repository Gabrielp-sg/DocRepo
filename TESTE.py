url_password: "{{ lookup('community.hashi_vault.hashi_vault', 'url=' ~ vault_url ~ ' secret=' ~ artifactory_reader_token_path ~ ' key=access_token') }}"
url_password: "{{ lookup('community.hashi_vault.hashi_vault', 'url=' ~ vault_url ~ ' secret=' ~ artifactory_reader_token_path ~ ' key=access_token') }}"
url_password: "{{ lookup('community.hashi_vault.hashi_vault', 'url=' ~ vault_url ~ ' secret=' ~ artifactory_reader_token_path ~ ' key=access_token') }}"


{
  "msg": "An unhandled exception occurred while running the lookup plugin 'community.hashi_vault.hashi_vault'. Error was a <class 'ansible.errors.AnsibleError'>, original message: No setting was provided for required configuration plugin_type: lookup plugin: ansible_collections.community.hashi_vault.plugins.lookup.hashi_vault setting: secret . No setting was provided for required configuration plugin_type: lookup plugin: ansible_collections.community.hashi_vault.plugins.lookup.hashi_vault setting: secret ",
  "_ansible_no_log": false
}

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


- name: Fetch OpenJDK Corretto 22 from jfrog
  ansible.builtin.get_url:
    url: "{{ artifactory_url }}/{{ wkl_virt_repo_name }}/{{ corretto_pkg }}"
    url_username: "{{ artifactory_reader_user }}"
    url_password: "{{ lookup('community.hashi_vault.hashi_vault','secret=' ~ artifactory_reader_token_path ~ ':access_token','url=' ~ vault_url) }}"
    dest: "/tmp/{{ corretto_pkg }}"


- name: Install OpenJDK Corretto 22
  ansible.builtin.yum:
    name: "/tmp/{{ corretto_pkg }}"
    state: present
    disable_gpg_check: true
  become: true

- name: Fetch the Apache Tomcat installer
  ansible.builtin.get_url:
    url: "{{ artifactory_url }}/{{ wkl_virt_repo_name }}/apache-tomcat-{{ tomcat_version }}.tar.gz"
    url_username: "{{ artifactory_reader_user }}"
    url_password: "{{ lookup('community.hashi_vault.hashi_vault','secret=' ~ artifactory_reader_token_path ~ ':access_token','url=' ~ vault_url) }}"
    dest: "{{ tomcat_archive }}"
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
    url_username: "{{ artifactory_reader_user }}"
    url_password: "{{ lookup('community.hashi_vault.hashi_vault','secret=' ~ artifactory_reader_token_path ~ ':access_token', 'url=' ~ vault_url) }}"
    dest: "/tmp/lpfat_fonts.zip"

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
  ansible.builtin.service:
    name: tomcat
    state: started

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
