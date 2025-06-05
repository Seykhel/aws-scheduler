# AWS Scheduler

Automates the start/stop lifecycle of EC2 and RDS resources using AWS Lambda and EventBridge. Terraform provisions the required infrastructure while Python Lambda functions perform the actions through Boto3.

## Repository Structure

```
.
├── lambda_layer.tf        # Lambda Layer configuration and local build setup
├── ec2_scheduler.tf       # EC2 scheduler module instantiation
├── rds_scheduler.tf       # RDS scheduler module instantiation
├── codebuild.tf           # S3 bucket configuration for artifacts
├── build_layer.sh         # Local build script for Lambda Layer
├── requirements.txt       # Python dependencies for the Lambda Layer
└── modules/               # Reusable Terraform modules
    ├── ec2_scheduler/     # EC2 automation
    └── rds_scheduler/     # RDS automation
```

## Key Features

1. **Automated Scheduling**
   - Start/stop EC2 instances based on tags
   - Start/stop RDS instances based on tags
   - Configurable schedule using cron expressions

2. **Infrastructure as Code**
   - Terraform for provisioning and management
   - Modular design for easy maintenance
   - Local build process for Lambda Layer

3. **Monitoring & Logging**
   - CloudWatch Logs for all Lambda executions
   - Detailed logging for troubleshooting

## Prerequisites

- Terraform >= 1.3
- AWS CLI configured with appropriate permissions
- Python 3.9+ for local development
- AWS credentials configured with sufficient permissions

## Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/aws-scheduler.git
   cd aws-scheduler
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Make the build script executable**
   ```bash
   chmod +x build_layer.sh
   ```

## Building the Lambda Layer Locally

The Lambda Layer is built locally using the `build_layer.sh` script. This script:

1. Creates a temporary directory for the layer
2. Installs dependencies from `requirements.txt`
3. Creates a ZIP archive of the dependencies

To manually build the layer:

```bash
./build_layer.sh
```

## Deploying with Terraform

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Review the execution plan**
   ```bash
   terraform plan
   ```

3. **Apply the configuration**
   ```bash
   terraform apply
   ```

   Terraform will automatically build the Lambda Layer and deploy all resources.

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AWS_REGION` | AWS region to deploy resources | `eu-west-1` |
| `github_repo_url` | GitHub repository URL | `https://github.com/your-repo/aws-scheduler.git` |

### Scheduler Configuration

- **EC2 Instances**: Tag your instances with `stopstart = enabled`
- **RDS Instances**: Tag your instances with `stopstart = enabled`

Default schedule (configurable in Terraform variables):
- **Start**: 13:00 local time
- **Stop**: 18:00 local time

## Monitoring

- **CloudWatch Logs**:
  - `/aws/lambda/dev-ec2-scheduler-to-start`
  - `/aws/lambda/dev-ec2-scheduler-to-stop`
  - `/aws/lambda/dev-rds-scheduler-to-start`
  - `/aws/lambda/dev-rds-scheduler-to-stop`

## Cleanup

To remove all resources:

```bash
terraform destroy
```

## Remote State

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
