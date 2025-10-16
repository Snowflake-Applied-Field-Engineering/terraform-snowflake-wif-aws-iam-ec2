# ami.tf

# OPTIONAL: if your org has a golden image, use var.ami_id to set the image to be used. Setting the var.ami_id will overide the following ami file. 
# The following ami file is used to auto-discover a current AL2023 or Ubuntu 22.04 image per region if not golden image is used.

# Amazon Linux 2023 (x86_64) - official Amazon owner
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Ubuntu 22.04 (Jammy) (x86_64) - official Canonical owner
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Choose the AMI ID:
# - If var.ami_id is provided, prefer that (golden image).
# - Else, pick based on var.os_family: "al2023" (default) or "ubuntu22.04".
locals {
  selected_ami_id = var.ami_id != "" ? var.ami_id : (var.os_family == "ubuntu22.04" ? data.aws_ami.ubuntu_2204.id : data.aws_ami.al2023.id)
}