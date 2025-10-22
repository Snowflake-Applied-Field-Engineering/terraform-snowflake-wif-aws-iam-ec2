# # iam.tf

# Trust policy: allow EC2 to assume this role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
  tags               = local.common_tags
}

# Attach SSM core so you can use Session Manager (no inbound SSH needed)
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Instance profile to attach the role to the EC2 instance
resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}-profile"
  role = aws_iam_role.ec2.name
  tags = local.common_tags
}

