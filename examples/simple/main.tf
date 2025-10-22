################################################################################
# Module
################################################################################
module "snowflake_wif_aws_iam_ec2" {
  source = "../../" # TODO Because examples will often be copied into other repositories for customization, any module blocks should have their source set to the address an external caller would use, not to a relative path.  https://developer.hashicorp.com/terraform/language/modules/develop/structure


  name_prefix = "sf-wif-tf-template"
  tags = {
    Environment = "dev"
    Project     = "demo"
    ManagedBy   = "terraform"
  }
  # AWS Infrastructure
  ## TODO figure out how to allow this to be testable but NOT include actual account info in the repo
  # region    = var.region 
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  # Snowflake Provider Authentication (for Terraform)
  snowflake_organization_name = var.snowflake_organization_name
  snowflake_account_name      = var.snowflake_account_name
  snowflake_username          = var.snowflake_username
  snowflake_role              = var.snowflake_role

  # WIF Test Resources (to be created in Snowflake)
  wif_user_name = var.wif_user_name
  wif_role_name = var.wif_role_name

  # NOTE: Depending on the authentication being used to connect Terraform to Snowflake, you may also want to include variables for key pair location if using key pair.
  # Example: snowflake_private_key_path = "<KEY PATH HERE>"
  snowflake_private_key_passphrase = var.snowflake_private_key_passphrase
  snowflake_private_key_path       = var.snowflake_private_key_path
  wif_test_database                = var.wif_test_database

  instance_type = var.instance_type
  os_family     = var.os_family
  key_name      = var.key_name
}


################################################################################
# Supporting Resources
################################################################################
# N/A
