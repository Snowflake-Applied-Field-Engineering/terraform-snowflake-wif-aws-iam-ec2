# Security Group for Snowflake WIF Test EC2 Instance
resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for Snowflake WIF test EC2 instance"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "${var.name_prefix}-sg"
    },
    local.common_tags
  )
}

# Default: Deny all inbound traffic (zero-trust)
# Access is provided exclusively via AWS SSM Session Manager
resource "aws_vpc_security_group_ingress_rule" "deny_all_inbound" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  from_port         = 0
  to_port           = 0
  description       = "Default deny all inbound traffic"
}



# Egress: Allow outbound HTTPS for package installation and Snowflake connectivity
resource "aws_vpc_security_group_egress_rule" "https_outbound" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Outbound HTTPS for package management, AWS SSM, and Snowflake API"
}

# Egress: Allow outbound HTTP (temporary - consider removing after initial setup)
resource "aws_vpc_security_group_egress_rule" "http_outbound" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "Outbound HTTP for package management (temporary)"
}

# Egress: Allow NTP for time synchronization
resource "aws_vpc_security_group_egress_rule" "ntp_outbound" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "udp"
  from_port         = 123
  to_port           = 123
  description       = "Outbound NTP for time synchronization"
}

# --- Future Hardening Recommendations ---
# Uncomment and customize these rules for production environments:

/*
# Production: Restrict Snowflake connectivity to specific regions
resource "aws_vpc_security_group_egress_rule" "snowflake_restricted" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "192.168.0.0/16" # Example: Replace with actual Snowflake IP ranges
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Egress to Snowflake API endpoints"
}

# Production: Use VPC Endpoints to avoid public internet egress
# Create endpoints for: ssmmessages, ssm, ec2messages, and s3 (for SSM)
resource "aws_vpc_security_group_egress_rule" "vpc_endpoints" {
  security_group_id = aws_security_group.ec2.id
  prefix_list_id    = aws_vpc_endpoint.ssm.prefix_list_id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Egress to AWS VPC Endpoints"
}
*/
