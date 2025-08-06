- hosts: "{{ target }}"
  gather_facts: yes
  vars:
    ansible_aws_ssm_instance_id : "{{ instance_id }}"
  tasks:
    - name: "Install LPFAT required tools"
      include_tasks: "tasks/install_lpfat_tools.yml"
