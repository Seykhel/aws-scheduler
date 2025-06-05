output "lambda_function_arns" {
  description = "ARNs of the Lambda functions per action"
  value       = { for k, v in aws_lambda_function.ec2 : k => v.arn }
}
