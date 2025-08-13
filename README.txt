{
  "msg": "Error mounting /mnt/bradesco/entrada: mount error: could not resolve address for ec2-0072-a-sae1-lpfatwin-lp: Unknown error\n",
  "invocation": {
    "module_args": {
      "src": "//ec2-0072-a-sae1-lpfatwin-lp/ENTRADA",
      "path": "/mnt/bradesco/entrada",
      "fstype": "cifs",
      "opts": "vers=3.1.1,credentials=/etc/samba/cred_lpfat,uid=1000,gid=1000",
      "state": "mounted",
      "boot": true,
      "dump": "0",
      "passno": "0",
      "backup": false,
      "fstab": null
    }
  },
  "_ansible_no_log": false,
  "changed": false,
  "item": "ENTRADA",
  "ansible_loop_var": "item",
  "_ansible_item_label": "ENTRADA"
}
