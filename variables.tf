# variables.tf

variable "region" {
  description = "AWS region to deploy into"
  type        = string

}

variable "vpc_id" {
  description = "Existing VPC ID where the test instance will run"
  type        = string

}

variable "subnet_id" {
  description = "Subnet ID for the test instance (private subnet recommended with SSM access)"
  type        = string

}

variable "name_prefix" {
  description = "Prefix to apply to resource names"
  type        = string
  default     = "snow-tf-wif-test"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "allow_ssh" {
  description = "Whether to allow inbound SSH (default false; use SSM Session Manager instead)"
  type        = bool
  default     = false
}

variable "ssh_cidr" {
  description = "CIDR block to allow SSH from, if allow_ssh = true"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Optional EC2 key pair name (required if using SSH)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "os_family" {
  description = "Base OS to use for the test instance (al2023 or ubuntu22.04)"
  type        = string
  default     = "al2023"
}

variable "ami_id" {
  description = "Optional override AMI ID (use this if you have a golden image)"
  type        = string
  default     = ""
}

# --- Snowflake-related variables (commented out for AWS-only template) ---
# Uncomment these when you want to configure the Snowflake provider and manage
# Snowflake resources (e.g., security integrations, roles).
variable "snowflake_organization_name" {
  description = "Snowflake org name"
  type        = string
}


variable "snowflake_account_name" {
  description = "Snowflake account locator (e.g., xy12345 or xy12345.us-east-1)"
  type        = string
}


variable "snowflake_role" {
  description = "Default role to use when applying Terraform resources in Snowflake"
  type        = string
}

variable "snowflake_username" {
  description = "Default user to use when applying Terraform resources in Snowflake"
  type        = string
}


variable "snowflake_private_key_path" {
  description = "Path to the PKCS#8 private key"
  type        = string
}

variable "snowflake_private_key_passphrase" {
  description = "Passphrase for the private key"
  type        = string
  sensitive   = true
}

# Identity objects
variable "wif_user_name" {
  description = "Name of the Snowflake WIF test user (e.g., WIF_TEST_USER)"
  type        = string
  default     = "WIF_TEST_USER"
}

variable "wif_user_login_name" {
  description = "LOGIN_NAME for the WIF test user (often same as name)"
  type        = string
  default     = "WIF_TEST_USER"
}

variable "wif_role_name" {
  description = "Name of the WIF test role"
  type        = string
  default     = "WIF_TEST_ROLE"
}


# Optional defaults for convenience
variable "wif_default_warehouse" {
  description = "Default warehouse for the WIF test user/role (must exist)"
  type        = string
  default     = null
}

variable "wif_test_database" {
  description = "Database to test privileges of the WIF test user/role(must exist)"
  type        = string

}

variable "wif_test_schema" {
  description = "Schema to test privileges of the WIF test user/role(must exist)"
  type        = string
  default     = null
}

# AWS WIF role variable
variable "aws_wif_role_arn" {
  description = "Optional Override ARN - AWS role ARN to use for WIF (if not provided, uses EC2 instance role)"
  type        = string
  default     = ""
}
