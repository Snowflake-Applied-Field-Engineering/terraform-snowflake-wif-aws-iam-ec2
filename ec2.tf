# ec2.tf

resource "aws_instance" "this" {
  ami                         = local.selected_ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = true

  # Pass in the rendered user-data from locals.tf (templatefile of userdata.sh.tmpl)
  user_data                   = local.user_data
  user_data_replace_on_change = true

  # Enforce IMDSv2 (no legacy IMDSv1 credentials access)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  # Encrypt the root volume (uses default EBS KMS key unless you've set a default CMK)
  root_block_device {
    encrypted = true
  }

  # Optional SSH keypair (kept null unless you set var.key_name)
  key_name = var.key_name

  tags = merge(
    {
      Name = "${var.name_prefix}-ec2"
    },
    local.common_tags
  )
}

# --- Notes ---
# - ami is chosen in ami.tf and exposed via local.selected_ami_id:
#     locals { selected_ami_id = var.ami_id != "" ? var.ami_id :
#       (var.os_family == "ubuntu22.04" ? data.aws_ami.ubuntu_2204.id : data.aws_ami.al2023.id) }
#
# - user_data is rendered in locals.tf:
#     locals { user_data = templatefile("${path.module}/userdata.sh.tmpl", {...}) }
#
# - SSM access is enabled via the role in iam.tf (AmazonSSMManagedInstanceCore) and instance profile in iam.tf