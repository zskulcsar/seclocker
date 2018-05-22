# The profile needs to be set using the access keys provided
provider "aws" {
  profile     = "${var.aws_profile}"
  region      = "${var.aws_region}"
}

############
# CW logs
####
resource "aws_cloudwatch_log_group" "ws_log" {
  name              = "ws_log"
  retention_in_days = "${var.retention_in_days}"
  tags              = {
    Terraform     = "true"
    Environment   = "${var.environment}"
    owner         = "${var.owner}"
    owner.email   = "${var.owner_email}"
  }
}
