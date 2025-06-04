# aws-scheduler

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

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

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Running tests

Install the development dependencies and run `pytest` from the repository root:

```bash
pip install pytest boto3 moto
pytest
```
