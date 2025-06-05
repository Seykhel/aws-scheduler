# aws-scheduler


## Running tests

Install the development dependencies and run `pytest` from the repository root.
Terraform must also be available in `PATH` so that the infrastructure code can
be validated during the test run:

```bash
pip install pytest boto3
pytest
```

## Remote state

State is stored in an S3 bucket with a DynamoDB table for locking. Update the
`backend` configuration in `versions.tf` with your bucket and table names before
running `terraform init`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_scheduler_default"></a> [ec2\_scheduler\_default](#module\_ec2\_scheduler\_default) | ./modules/ec2_scheduler | n/a |
| <a name="module_rds_scheduler_default"></a> [rds\_scheduler\_default](#module\_rds\_scheduler\_default) | ./modules/rds_scheduler | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy resources | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_scheduler_lambda_arns"></a> [ec2\_scheduler\_lambda\_arns](#output\_ec2\_scheduler\_lambda\_arns) | ARNs of the EC2 scheduler Lambda functions |
| <a name="output_rds_scheduler_lambda_arns"></a> [rds\_scheduler\_lambda\_arns](#output\_rds\_scheduler\_lambda\_arns) | ARNs of the RDS scheduler Lambda functions |
<!-- END_TF_DOCS -->
