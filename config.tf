variable "scheduler_config" {
  description = "Configuration for EC2 and RDS schedulers"
  type = object({
    ec2 = object({
      start_time = string
      stop_time = string
      weekdays = bool
    })
    rds = object({
      start_time = string
      stop_time = string
      weekdays = bool
    })
  })
  default = {
    ec2 = {
      start_time = "13:00"
      stop_time = "18:00"
      weekdays = true
    }
    rds = {
      start_time = "13:00"
      stop_time = "18:00"
      weekdays = true
    }
  }
}

locals {
  aws_region_timezone_map = {
    "us-east-1"   = "America/New_York"    # US East (N. Virginia)
    "us-east-2"   = "America/Chicago"     # US East (Ohio)
    "us-west-1"   = "America/Los_Angeles" # US West (N. California)
    "us-west-2"   = "America/Los_Angeles" # US West (Oregon)
    "eu-west-1"   = "Europe/Ireland"      # Europe (Ireland)
    "eu-central-1" = "Europe/Berlin"      # Europe (Frankfurt)
    "eu-west-2"   = "Europe/London"       # Europe (London)
    "eu-west-3"   = "Europe/Paris"        # Europe (Paris)
    "eu-north-1"  = "Europe/Stockholm"    # Europe (Stockholm)
    "ap-southeast-1" = "Asia/Singapore"   # Asia Pacific (Singapore)
    "ap-southeast-2" = "Australia/Sydney" # Asia Pacific (Sydney)
    "ap-northeast-1" = "Asia/Tokyo"       # Asia Pacific (Tokyo)
    "ap-northeast-2" = "Asia/Seoul"       # Asia Pacific (Seoul)
    "ap-south-1"   = "Asia/Kolkata"      # Asia Pacific (Mumbai)
    "sa-east-1"    = "America/Sao_Paulo"  # South America (Sao Paulo)
    "ca-central-1" = "America/Toronto"    # Canada (Central)
  }

  region_timezone = lookup(local.aws_region_timezone_map, var.region, "UTC")
  
  # Mappa statica degli offset orari per ogni fuso orario (in ore rispetto a UTC)
  timezone_offsets = {
    "America/New_York"    = -4  # EDT (Daylight Saving Time)
    "America/Chicago"     = -5  # CDT (Daylight Saving Time)
    "America/Los_Angeles" = -7  # PDT (Daylight Saving Time)
    "Europe/Ireland"      = 1   # IST (Irish Standard Time)
    "Europe/Berlin"       = 2   # CEST (Daylight Saving Time)
    "Europe/London"       = 1   # BST (Daylight Saving Time)
    "Europe/Paris"        = 2   # CEST (Daylight Saving Time)
    "Europe/Stockholm"    = 2   # CEST (Daylight Saving Time)
    "Asia/Singapore"      = 8   # SGT (no DST)
    "Australia/Sydney"    = 10  # AEST (Daylight Saving Time)
    "Asia/Tokyo"          = 9   # JST (no DST)
    "Asia/Seoul"          = 9   # KST (no DST)
    "Asia/Kolkata"        = 5.5 # IST (no DST)
    "America/Sao_Paulo"   = -3  # BRT (no DST)
    "America/Toronto"     = -4  # EDT (Daylight Saving Time)
  }

  # Ottieni l'offset orario per la regione corrente
  current_offset = lookup(local.timezone_offsets, local.region_timezone, 0)

  # Funzione per convertire l'ora locale in UTC
  local_to_utc = {
    for time in [
      {
        name = "ec2_start"
        hour = split(":", var.scheduler_config.ec2.start_time)[0]
      },
      {
        name = "ec2_stop"
        hour = split(":", var.scheduler_config.ec2.stop_time)[0]
      },
      {
        name = "rds_start"
        hour = split(":", var.scheduler_config.rds.start_time)[0]
      },
      {
        name = "rds_stop"
        hour = split(":", var.scheduler_config.rds.stop_time)[0]
      }
    ] : time.name => format("%02d", (tonumber(time.hour) - local.current_offset) % 24)
  }

  ec2_start_utc = local.local_to_utc["ec2_start"]
  ec2_stop_utc  = local.local_to_utc["ec2_stop"]
  rds_start_utc = local.local_to_utc["rds_start"]
  rds_stop_utc  = local.local_to_utc["rds_stop"]

  # Crea le espressioni cron per AWS EventBridge
  # Formato: cron(minuti ore giorno-del-mese mese giorno-della-settimana anno)
  # Giorni settimana: 1-7 (1=lunedì, 7=domenica) o MON-FRI
  ec2_cron = var.scheduler_config.ec2.weekdays ? "cron(0 ${local.ec2_start_utc} ? * 2-6 *)" : "cron(0 ${local.ec2_start_utc} * * ? *)"
  rds_cron = var.scheduler_config.rds.weekdays ? "cron(0 ${local.rds_start_utc} ? * 2-6 *)" : "cron(0 ${local.rds_start_utc} * * ? *)"
}

output "scheduler_times" {
  description = "Converted times for each region"
  value = {
    region = "us-east-1"
    region_timezone = local.region_timezone
    ec2_start_local = var.scheduler_config.ec2.start_time
    ec2_start_utc = local.ec2_start_utc
    ec2_stop_local = var.scheduler_config.ec2.stop_time
    ec2_stop_utc = local.ec2_stop_utc
    rds_start_local = var.scheduler_config.rds.start_time
    rds_start_utc = local.rds_start_utc
    rds_stop_local = var.scheduler_config.rds.stop_time
    rds_stop_utc = local.rds_stop_utc
  }
}
