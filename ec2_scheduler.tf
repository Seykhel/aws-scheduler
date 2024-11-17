module "ec2_scheduler_default" {
  source              = "./modules/ec2_scheduler"
  name                = "dev-ec2-scheduler"
  stop_cron_schedule  = "cron(00 18 ? * MON-FRI *)"
  start_cron_schedule = "cron(00 13 ? * MON-FRI *)"

  tags = {
    Owner  = "ACME"
    Author = "Seykhel"
    Env    = "dev"
  }
}