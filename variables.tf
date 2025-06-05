variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "github_repo_url" {
  description = "URL of the GitHub repository containing the source code"
  type        = string
  default     = "https://github.com/your-repo/aws-scheduler.git"
}