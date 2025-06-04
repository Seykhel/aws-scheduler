# This file contains the variable definitions for the RDS Scheduler module.

# The "name" variable is used as a prefix for the resources' names.
variable "name" {
  description = "Prefix to use for resources name"
  default     = "rds-scheduler"
}

# The "stopstart_tags" variable is used to enable STOP/START for RDS Instances with the specified tag.
variable "stopstart_tags" {
  description = "Enable STOP/START for RDS Instances with the following tag"
  default = {
    TagKEY   = "stopstart"
    TagVALUE = "enabled"
  }
}

# The "stop_cron_schedule" variable defines the Cron Expression for when to STOP Servers in UTC Time zone.
variable "stop_cron_schedule" {
  description = "Cron Expression when to STOP Servers in UTC Time zone"
  default     = "cron(00 17 * * ? *)"
}

# The "start_cron_schedule" variable defines the Cron Expression for when to START Servers in UTC Time zone.
variable "start_cron_schedule" {
  description = "Cron Expression when to START Servers in UTC Time zone"
  default     = "cron(00 09 * * ? *)"
}

# The "tags" variable defines the tags to apply to resources.
variable "tags" {
  description = "Tags to apply to resources"
  default = {
    Developer = "ACME"
    Author    = "Seykhel"
  }
}
