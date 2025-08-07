Expor diretórios Scopus(BRADESCO) na EC2 Linux

Adicionar

Apps
Descrição

Diretórios que precisam ser mapeados no Linux:

C:\STCPCLT_BRADESCO\O0055BRADESCO\ENTRADA

C:\STCPCLT_BRADESCO\O0055BRADESCO\SAIDA

O EBS é o que anexado a EC2 windows do LpFAT.

podemos já ir para o próximo issue do lpfat que é expor dois diretórios de um ebs para a ec2 onde ta rodando a aplicação
acho que tem um card lá disso, se não tiver eu vou criar com as pastas 

# role: windows_share.yml
- name: Create SMB shares
  win_share:
    path: C:\STCPCLT_BRADESCO\O0055BRADESCO\{{ item }}
    name: "{{ item }}"
    full: LpFATUser
  loop:
    - ENTRADA
    - SAIDA

# role: linux_mount.yml
- name: Ensure CIFS share mounted
  mount:
    src: "//{{ win_ip }}/{{ item }}"
    path: "/mnt/bradesco/{{ item | lower }}"
    fstype: cifs
    opts: "vers=3.1.1,credentials=/etc/samba/cred_lpfat,uid=1000,gid=1000"
    state: mounted
  loop:
    - ENTRADA
    - SAIDA


resource "aws_security_group_rule" "allow_smb_to_windows" {
  type              = "ingress"
  from_port         = 445
  to_port           = 445
  protocol          = "tcp"
  security_group_id = aws_security_group.win_sg.id
  source_security_group_id = aws_security_group.linux_sg.id
}

    
