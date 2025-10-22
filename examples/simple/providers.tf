# AWS Provider
provider "aws" {
  region = var.region
}

# Snowflake Provider
# Authentication Options:
# Option A: Key-pair authentication (current configuration)
# Option B: OAuth - comment out below and use OAuth variables instead

provider "snowflake" {
  organization_name = var.snowflake_organization_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_username
  role              = var.snowflake_role
  authenticator     = "SNOWFLAKE_JWT" # Requires private_key and corresponding public key setup
  private_key       = file(var.snowflake_private_key_path)

  # Optional: Enable preview features if needed
  preview_features_enabled = ["snowflake_current_account_datasource"]
}
