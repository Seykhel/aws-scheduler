resource "aws_lambda_layer_version" "scheduler_layer" {
  filename            = "scheduler_layer.zip"
  layer_name         = "scheduler-common"
  description        = "Common modules for scheduler Lambdas"
  source_code_hash   = fileexists("scheduler_layer.zip") ? filebase64sha256("scheduler_layer.zip") : null
  compatible_runtimes = ["python3.9"]
}

output "lambda_layer_arn" {
  description = "ARN of the scheduler Lambda layer"
  value       = aws_lambda_layer_version.scheduler_layer.arn
}
