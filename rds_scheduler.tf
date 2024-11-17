module "rds_scheduler_default" {
  source              = "./modules/rds_scheduler"
  name                = "dev-rds-scheduler"
  stop_cron_schedule  = "cron(00 18 ? * MON-FRI *)"
  start_cron_schedule = "cron(00 13 ? * MON-FRI *)"

  tags = {
    Owner  = "ACME"
    Author = "Seykhel"
    Env    = "dev"
  }
}