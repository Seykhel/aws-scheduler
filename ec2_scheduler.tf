module "ec2_scheduler_default" {
  source              = "./modules/ec2_scheduler"
  name                = "dev-ec2-scheduler"
  stop_cron_schedule  = local.ec2_cron
  start_cron_schedule = local.ec2_cron
  scheduler_layer_arn = aws_lambda_layer_version.scheduler_layer.arn

  tags = {
    Owner  = "ACME"
    Author = "Seykhel"
    Env    = "dev"
  }
}