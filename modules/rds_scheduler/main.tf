# This Terraform file defines resources for scheduling start and stop actions on RDS instances using AWS Lambda and CloudWatch Events.

locals {
  scheduler_actions = {
    stop  = var.stop_cron_schedule
    start = var.start_cron_schedule
  }
}

#--------------- Lambda---------------------------------------------------------
resource "aws_lambda_function" "rds" {
  for_each         = local.scheduler_actions
  function_name    = "${var.name}-to-${each.key}"
  description      = "Lambda to ${each.key} RDS Instances with specific Tag"
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  tags             = var.tags
  timeout          = 10

  environment {
    variables = {
      RDSTAG_KEY   = var.stopstart_tags["TagKEY"]
      RDSTAG_VALUE = var.stopstart_tags["TagVALUE"]
      RDS_ACTION   = upper(each.key)
    }
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "rds_lambda_function.zip"
  source {
    filename = "lambda_function.py"
    content  = file("${path.module}/main.py")
  }
}

#--------------- Lambda IAM Permissions-----------------------------------------
resource "aws_iam_role" "lambda" {
  name               = "${var.name}-iam-role"
  tags               = var.tags
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": ["lambda.amazonaws.com"]
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "lambda" {
  name   = "${var.name}-policy"
  tags   = var.tags
  policy = <<EOF
{
            "Version": "2012-10-17",
            "Statement": [
                    {
                            "Sid"   : "LoggingPermissions",
                            "Effect": "Allow",
                            "Action": [
                                    "logs:CreateLogGroup",
                                    "logs:CreateLogStream",
                                    "logs:PutLogEvents"
                            ],
                            "Resource": [
                                    "arn:aws:logs:*:*:*"
                            ]
                    },
                    {
                            "Sid"   : "WorkPermissions",
                            "Effect": "Allow",
                            "Action": [
                                    "rds:DescribeDBInstances",
                                    "rds:StopDBInstance",
                                    "rds:StartDBInstance"
                            ],
                            "Resource": "*"
                    }
            ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = "${var.name}-role-policy-attach"
  roles      = [aws_iam_role.lambda.name]
  policy_arn = aws_iam_policy.lambda.arn
}

#---------------Logging---------------------------------------------------------
resource "aws_cloudwatch_log_group" "lambda" {
  for_each          = local.scheduler_actions
  name              = "/aws/lambda/${var.name}-to-${each.key}"
  retention_in_days = 7
  tags              = var.tags
}

#--------------- Lambda Triggers------------------------------------------------
resource "aws_cloudwatch_event_rule" "rds" {
  for_each            = local.scheduler_actions
  name                = "${var.name}-trigger-to-${each.key}-rds"
  description         = "Invoke Lambda via AWS EventBridge"
  schedule_expression = each.value
  tags                = var.tags
}

resource "aws_lambda_permission" "rds" {
  for_each      = local.scheduler_actions
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds[each.key].arn
}

resource "aws_cloudwatch_event_target" "rds" {
  for_each = local.scheduler_actions
  rule     = aws_cloudwatch_event_rule.rds[each.key].name
  arn      = aws_lambda_function.rds[each.key].arn
}

