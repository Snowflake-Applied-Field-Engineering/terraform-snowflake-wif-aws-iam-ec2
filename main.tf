module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  # version = "6.1.4"

  name = var.name_prefix

  # ami                    = data.aws_ami.amazon_linux.id
  ami           = local.selected_ami_id
  instance_type = var.instance_type

  # instance_type          = "c5.xlarge" # used to set core count below
  # availability_zone      = element(module.vpc.azs, 0)
  # subnet_id              = element(module.vpc.private_subnets, 0)
  subnet_id = var.subnet_id
  # vpc_security_group_ids = [module.security_group.security_group_id]
  # placement_group        = aws_placement_group.web.id
  # create_eip             = true
  # disable_api_stop       = false


  iam_instance_profile = aws_iam_instance_profile.this.name # TODO indicate this has WIF?? 
  # create_iam_instance_profile = true
  # iam_role_description        = "IAM role for EC2 instance with SSM access."
  # iam_role_policies = {
  #   AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  # }

  user_data_base64 = base64encode(local.user_data)
  # user_data_replace_on_change = false

  # Enforce IMDSv2 and increase hop limit # TODO WHY increase? Not using docker
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  key_name = var.key_name


  # cpu_options = {
  #   core_count       = 2
  #   threads_per_core = 1
  # }
  # enable_volume_tags = false
  root_block_device = {
    encrypted = true
    type      = "gp3"
    #   throughput = 200
    #   size       = 50
    #   tags = {
    #     Name = "my-root-block"
    #   }
  }

  # ebs_volumes = {
  #   "/dev/sdf" = {
  #     size       = 5
  #     throughput = 200
  #     encrypted  = true
  #     kms_key_id = aws_kms_key.this.arn
  #     tags = {
  #       MountPoint = "/mnt/data"
  #     }
  #   }
  # }



  security_group_description = "Security group for Snowflake WIF EC2 instance."
  security_group_egress_rules = {
    https_outbound = {
      description = "Outbound HTTPS for package management, Snowflake API, and SSM endpoints"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    },
    http_outbound = {
      description = "Outbound HTTP for package management (temporary - consider removing after initial setup)"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    },
    ntp_outbound = {
      description = "Outbound NTP for time synchronization"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "udp"
      from_port   = 123
      to_port     = 123
    }
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-ec2"
    },
    local.common_tags
  )
}
