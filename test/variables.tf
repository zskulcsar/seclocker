#
variable "aws_profile" {
  description = "the AWS profile to be used with the VPC"
}

variable "owner" {
  description = "the owner of the resources"
}

variable "owner_email" {
  description = "the email for the owner" 
}

variable "ssh_ingress_cidr" {
  description = "The ingress cidr for the SSH access"
}

variable "ssh_key_name" {
  description = "The name of the SSH key to be used with the instance"
}

variable "ws_log_instance_profile" {
  description = "The name for the instance profile to be used with the instance"
}

# Parameters with sensible defaults
variable "ssh_access_config_location" {
  default = "/etc/cwlogs/sshaccess.conf"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "retention_in_days" {
  description = "The retention period in days for the logs"
  default = "7"
}