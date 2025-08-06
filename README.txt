[DEPRECATION WARNING]: The default value for 'token_validate' will change from 
True to False. This feature will be removed from community.hashi_vault in 
version 4.0.0. Deprecation warnings can be disabled by setting 
deprecation_warnings=False in ansible.cfg.
[defaults]
connection_plugins = :~/.ansible/plugins/connection:/home/awx/.ansible/plugins/connection/




- hosts: "{{ target }}"
  gather_facts: yes
  vars:
    ansible_aws_ssm_instance_id : "{{ instance_id }}"
  tasks:
    - name: "Install LPFAT required tools"
      include_tasks: "tasks/install_lpfat_tools.yml"


ERROR! The field 'hosts' has an invalid value, which includes an undefined variable. The error was: 'target' is undefined
The error appears to be in '/runner/project/callback.yml': line 1, column 3, but may
be elsewhere in the file depending on the exact syntax problem.
The offending line appears to be:
- hosts: "{{ target }}"
  ^ here
We could be wrong, but this one looks like it might be an issue with
missing quotes. Always quote template expression brackets when they
start a value. For instance:
    with_items:
      - {{ foo }}
Should be written as:
    with_items:
      - "{{ foo }}"
