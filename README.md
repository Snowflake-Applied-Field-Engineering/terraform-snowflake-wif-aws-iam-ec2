# Snowflake Workload Identity Federation (WIF) Test Environment

[![Terraform Validation](https://github.com/Snowflake-Applied-Field-Engineering/terraform-snowflake-wif-aws-iam-ec2/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/Snowflake-Applied-Field-Engineering/terraform-snowflake-wif-aws-iam-ec2/actions/workflows/terraform-validate.yml)

A Terraform module to deploy a test AWS EC2 instance for testing **Snowflake Workload Identity Federation (WIF)**. This enables secure authentication to Snowflake using an AWS IAM role, eliminating the need for password or key-based credentials.

## Architecture Summary

This module creates the following resources:

- **In AWS:**
  - An EC2 instance in a subnet of your choosing.
  - An IAM Role with a trust policy for Snowflake Workload Identity Federation (WIF).
  - A Security Group with minimal, necessary rules.
  - An IAM Instance Profile.

- **In Snowflake:**
  - A database Role (`WIF_TEST_ROLE`) with permissions.
  - A Service User (`WIF_TEST_USER`) configured with a the corresponding AWS IAM Role to enable `WORKLOAD_IDENTITY` authentication.
  - Permission grants on a warehouse, database, and schema set by you.

## Continuous Integration

This repository includes automated Terraform validation through GitHub Actions. The workflow runs on every push and pull request to ensure:

- ✅ Terraform configuration is properly formatted (`terraform fmt`)
- ✅ Terraform initialization succeeds (`terraform init`)
- ✅ Terraform configuration is valid (`terraform validate`)

The status badge at the top of this README shows the current validation status.

## Quick Start

### Prerequisites

- **Terraform** >= 1.5.0
- A configured Terraform to Snowflake connection - A Snowflake user with appropriate permissions to support Terraform automation in Snowflake
- **Snowflake** ACCOUNTADMIN privileges may also help to confirm resouces
- **AWS CLI** configured with appropriate permissions
- An existing AWS **VPC and private subnet**

### Deployment Steps

1. **Clone the Repository**

- Choose the file location to host the repo and clone the repository and navigate into the repo.

    ```bash
    git clone git@github.com:Snowflake-Applied-Field-Engineering/terraform-snowflake-wif-aws-iam-ec2.git
    cd terraform-snowflake-wif-aws-iam-ec2
    ```

1. **Configure Variables**
    - Create a `terraform.tfvars` file with your specific values:

    ```hcl
    # AWS Infrastructure
    region    = "your AWS region"
    vpc_id    = "vpc-yourvpcid"
    subnet_id = "subnet-yoursubnetid"

    # Snowflake Provider Authentication (for Terraform)
    snowflake_account_name = "your_account_identifier"
    snowflake_username     = "your_terraform_user"
    snowflake_role         = "ACCOUNTADMIN"

    # WIF Test Resources (to be created in Snowflake)
    wif_user_name = "WIF_TEST_USER"
    wif_role_name = "WIF_TEST_ROLE"

    # NOTE: Depending on the authentication being used to connect Terraform to Snowflake, you may also want to include variables for key pair location if using key pair.
    # Example: snowflake_private_key_path = "<KEY PATH HERE>"

    ```

1. **Deploy the Infrastructure**
    - Once you have your access confirmed and variables configured, run your Terraform commands to deploy your resources via Terraform

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

1. **Connect and Test**
    - Connect to the test instance via AWS SSM Session Manager. Connection can be made via AWS CLI or via the AWS consol UI. For UI connection, navigate to created EC2 instance, right click > connect > SSM Session Manager
    For AWS CLI complete the following :

    ```bash
    aws ssm start-session --target $(terraform output -raw instance_id)
    ```

    Once connected, activate the environment and run the test script:

    ```bash
    sudo su -
    source /opt/snowflake-test/venv/bin/activate
    python3 /opt/snowflake-test/test_snowflake.py
    ```
