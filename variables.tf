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

variable "aws_region" {
  default = "eu-west-1"
}

variable "retention_in_days" {
  description = "The retention period in days for the logs"
  default = "7"
}

variable "environment" {
  description = "The environment designation"
  default = "test"
}