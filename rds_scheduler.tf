module "rds_scheduler_default" {
  source              = "./modules/rds_scheduler"
  name                = "dev-rds-scheduler"
  stop_cron_schedule  = local.rds_cron
  start_cron_schedule = local.rds_cron
  scheduler_layer_arn = aws_lambda_layer_version.scheduler_layer.arn

  tags = {
    Owner  = "ACME"
    Author = "Seykhel"
    Env    = "dev"
  }
}