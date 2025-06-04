**General overview**

The repository contains a small Terraform/Python project that automates starting and stopping AWS resources (EC2 and RDS) using Lambda and EventBridge.

At the **root** there are a few main files:

- `ec2_scheduler.tf` and `rds_scheduler.tf` instantiate the Terraform modules that manage scheduling for EC2 and RDS respectively, setting names, cron expressions, and tags.
- `README.md` lists the modules and does not require specific providers.
- `.pre-commit-config.yaml` defines hooks to format and document Terraform code.

Under the `modules/` directory there are two Terraform modules:

### `modules/ec2_scheduler`
- The README clearly explains what gets deployed: stop/start Lambda functions, EventBridge rules, log groups, and IAM policies.
- `main.tf` provisions the infrastructure: environment variables for the Lambda, scheduled triggers, IAM roles/policies, log configuration, and EventBridge rules/targets.
- `variables.tf` declares configurable parameters (resource names, tags, default cron schedules).
- `main.py` contains the Lambda logic: it reads environment variables, filters EC2 instances by tag, and starts or stops them.

### `modules/rds_scheduler`
- Follows the same structure as the EC2 module. The README describes the deployed components.
- `main.tf` creates the Lambda and all components needed to manage RDS instances.
- `variables.tf` handles parameters (resource names, tags, cron schedules).
- `main.py` starts or stops RDS instances using the same approach as for EC2.

Each module includes a diagram image in `img/readme.png` that illustrates the flow.

**Key concepts**

1. **Lambda and Boto3**  
   The Python functions use Boto3 to query and change the state of EC2 or RDS. Tags and the desired action (START/STOP) are provided through environment variables.
2. **EventBridge**  
   Trigger rules (`aws_cloudwatch_event_rule`) with cron expressions execute the Lambda functions on a schedule.
3. **IAM and Logging**  
   Each module creates a minimal IAM role and policy, plus a CloudWatch log group to capture function output.
4. **Customization**  
   The module READMEs show how to use the module with default or customized cron schedules and tags.

**Suggestions for further study**

- **Terraform**: Learn more about modules, variables, and outputs, and how to extend configurations (e.g., multiple regions or different tag criteria).
- **AWS EventBridge & Lambda**: Understand cron expressions in UTC and how to manage Lambda permissions.
- **Python/Boto3**: Explore methods such as `describe_instances`, `stop_instances`, `start_instances`, along with `describe_db_instances`, `stop_db_instance`, and `start_db_instance`.
- **Pre-commit**: Set up the hooks in `.pre-commit-config.yaml` to run `terraform fmt` and generate documentation before committing.

This project demonstrates a straightforward way to automate the lifecycle of EC2 and RDS instances with Terraform, Lambda, and EventBridge. Knowing these components well is the next step toward customizing or integrating the project into a more complex environment.
