# snowflake.tf

# Confirm provider connectivity
data "snowflake_current_account" "this" {}

output "snowflake_current_account" {
  description = "Account locator of the Snowflake account Terraform is connected to"
  value       = data.snowflake_current_account.this.account
}

################################################################################
# snowflake.tf — WIF role, user, and grants
################################################################################

# 0) Pick the AWS role ARN to bind as the workload identity:
#    - If var.aws_wif_role_arn is provided, use it
#    - Otherwise, default to the EC2 instance role ARN we created in iam.tf
locals {
  wif_role_arn_effective = (
    var.aws_wif_role_arn != "" ? var.aws_wif_role_arn : aws_iam_role.ec2.arn
  )
}

# 1) Create the WIF test role in Snowflake
resource "snowflake_account_role" "wif_test_role" {
  name    = var.wif_role_name
  comment = "Role for AWS→Snowflake WIF test user (Terraform-managed)"
}

# 2) Create the WIF service user via exact SQL (TYPE=SERVICE + WORKLOAD_IDENTITY)
#    We use snowflake_execute because the snowflake_user resource does not yet
#    expose WORKLOAD_IDENTITY/TYPE=SERVICE as first-class arguments.
resource "snowflake_execute" "wif_user_create" {
  # Ensure the role exists and the AWS role ARN is resolved first
  depends_on = [
    snowflake_account_role.wif_test_role
  ]

  # CREATE (idempotent), VERIFY (query), and DESTROY (revert)
  # Note: LOGIN_NAME is not needed for WIF users - authentication is via WORKLOAD_IDENTITY
  execute = <<SQL
CREATE USER IF NOT EXISTS ${var.wif_user_name}
  TYPE = SERVICE
  DEFAULT_ROLE = ${snowflake_account_role.wif_test_role.name}
  WORKLOAD_IDENTITY = (
    TYPE = AWS
    ARN  = '${local.wif_role_arn_effective}'
  )
  COMMENT = 'WIF service user (AWS role mapped) managed by Terraform';
SQL

  # Optional visibility during plan/apply
  query = "SHOW USERS LIKE '${var.wif_user_name}';"

  # Clean removal on destroy
  revert = "DROP USER IF EXISTS ${var.wif_user_name};"
}

# 3) Grant the WIF role to the WIF user
resource "snowflake_grant_account_role" "wif_role_to_user" {
  role_name  = snowflake_account_role.wif_test_role.name
  user_name  = var.wif_user_name
  depends_on = [snowflake_execute.wif_user_create]
}

# --- Optional: minimal usage grants so the user can run a quick query ---
# Guard each with count so nulls skip creation.

resource "snowflake_grant_privileges_to_account_role" "wif_wh_usage" {
  count             = var.wif_default_warehouse == null ? 0 : 1
  account_role_name = snowflake_account_role.wif_test_role.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.wif_default_warehouse
  }
}

resource "snowflake_grant_privileges_to_account_role" "wif_db_usage" {
  count             = var.wif_test_database == null ? 0 : 1
  account_role_name = snowflake_account_role.wif_test_role.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.wif_test_database
  }
}

resource "snowflake_grant_privileges_to_account_role" "wif_schema_usage" {
  count             = var.wif_test_schema == null ? 0 : 1
  account_role_name = snowflake_account_role.wif_test_role.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "${var.wif_test_database}.${var.wif_test_schema}"
  }
}


