resource "aws_ebs_volume" "additional_disks" {
  for_each = {
    for key, value in var.additional_disks :
    value.device_name => value
  }
  availability_zone = aws_instance.instance.availability_zone
  encrypted         = each.value.encrypted
  iops              = each.value.iops
  type              = each.value.type
  size              = each.value.size
  snapshot_id       = each.value.snapshot_id
  kms_key_id        = each.value.kms_key_id
  throughput        = each.value.throughput
  tags              = merge({ Name = var.name }, each.value.tags, local.tags)

}

resource "aws_volume_attachment" "additional_disks_attachment" {
  for_each    = aws_ebs_volume.additional_disks
  device_name = each.key
  volume_id   = each.value.id
  instance_id = aws_instance.instance.id
}
