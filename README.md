# aws-scheduler

Automates the start/stop lifecycle of EC2 and RDS resources using AWS Lambda and EventBridge. Terraform provisions the required infrastructure while Python Lambda functions perform the actions through Boto3.

## Repository structure

- `ec2_scheduler.tf` and `rds_scheduler.tf` instantiate the modules that schedule EC2 and RDS instances.
- `.pre-commit-config.yaml` contains hooks for formatting and documentation.
- `modules/` holds the reusable Terraform modules:
  - `ec2_scheduler/` – Terraform and Python code for EC2 automation.
  - `rds_scheduler/` – same structure for RDS.
- `tests/` provides a small pytest suite that validates both the Lambda functions and the Terraform configuration.

Each module deploys two Lambda functions (start and stop), EventBridge rules with cron expressions, log groups and IAM roles. The Python files (`main.py`) read tags and actions from environment variables to determine which resources to manage. Diagrams in `img/readme.png` under each module illustrate the flow.

## Key concepts

1. **Lambda and Boto3** – resource queries and actions are executed through the AWS SDK.
2. **EventBridge** – cron-based rules trigger the Lambda functions on schedule.
3. **IAM and logging** – each module provisions a minimal role and a CloudWatch log group.
4. **Customization** – cron expressions and tags can be overridden via module variables.

## Running tests

Install the development dependencies and run `pytest` from the repository root. Terraform must also be available in `PATH` so that the infrastructure code can be validated during the test run:

```bash
pip install pytest boto3
pytest
```

## Remote state

State is stored in an S3 bucket with a DynamoDB table for locking. Update the `backend` configuration in `versions.tf` with your bucket and table names before running `terraform init`.

## Suggestions for further study

- **Terraform** – explore modules, variables and outputs to customize deployments.
- **AWS EventBridge & Lambda** – learn how cron expressions work in UTC and how to manage permissions.
- **Python/Boto3** – check the methods used in the Lambda functions (`describe_instances`, `stop_instances`, `start_instances`, etc.).
- **Pre-commit** – enable the hooks in `.pre-commit-config.yaml` for formatting and documentation generation.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_scheduler_default"></a> [ec2_scheduler_default](#module_ec2_scheduler_default) | ./modules/ec2_scheduler | n/a |
| <a name="module_rds_scheduler_default"></a> [rds_scheduler_default](#module_rds_scheduler_default) | ./modules/rds_scheduler | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input_region) | AWS region to deploy resources | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_scheduler_lambda_arns"></a> [ec2_scheduler_lambda_arns](#output_ec2_scheduler_lambda_arns) | ARNs of the EC2 scheduler Lambda functions |
| <a name="output_rds_scheduler_lambda_arns"></a> [rds_scheduler_lambda_arns](#output_rds_scheduler_lambda_arns) | ARNs of the RDS scheduler Lambda functions |
<!-- END_TF_DOCS -->
