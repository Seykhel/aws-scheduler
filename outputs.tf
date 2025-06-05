output "ec2_scheduler_lambda_arns" {
  description = "ARNs of the EC2 scheduler Lambda functions"
  value       = module.ec2_scheduler_default.lambda_function_arns
}

output "rds_scheduler_lambda_arns" {
  description = "ARNs of the RDS scheduler Lambda functions"
  value       = module.rds_scheduler_default.lambda_function_arns
}
