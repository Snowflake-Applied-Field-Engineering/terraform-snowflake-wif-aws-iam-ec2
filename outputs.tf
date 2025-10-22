# outputs.tf

# --- AWS outputs ---

output "instance_id" {
  description = "ID of the EC2 test instance"
  value       = module.ec2_instance.id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 test instance"
  value       = module.ec2_instance.private_ip
}

output "ssm_start_session_command" {
  description = "Convenience command to start a Session Manager shell"
  # value       = "aws ssm start-session --target ${module.ec2_instance.id} --region ${data.aws_region.current.name}"
  value = "aws ssm start-session --target ${module.ec2_instance.id} --region ${data.aws_region.current.name}"
}

# Optional: show the selected AMI ID that was used (helpful for audits)
output "selected_ami_id" {
  description = "AMI ID used for the EC2 instance (either override or discovered)"
  value       = local.selected_ami_id
}

output "wif_role_arn" {
  description = "ARN of the AWS role used as the workload identity (attached to EC2)"
  value       = aws_iam_role.ec2.arn
}

# --- Snowflake outputs (commented out for now; enable when Snowflake provider/resources are added) ---
output "snowflake_account_name" {
  description = "Snowflake account locator used for provider/resources"
  value       = var.snowflake_account_name
}

output "snowflake_role_used" {
  description = "Snowflake role leveraged by Terraform when applying resources"
  value       = var.snowflake_role
}

# --- Handy outputs (optional; you can also place these in outputs.tf) ---
output "wif_role_arn_effective" {
  description = "AWS role ARN mapped to the Snowflake WIF user"
  value       = local.wif_role_arn_effective
}

output "wif_test_role" {
  description = "Snowflake role created for WIF testing"
  value       = snowflake_account_role.wif_test_role.name
}

output "wif_test_user" {
  description = "Snowflake WIF user created via WORKLOAD_IDENTITY"
  value       = var.wif_user_name
}

