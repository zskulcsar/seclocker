# The profile needs to be set using the access keys provided
provider "aws" {
  profile     = "${var.aws_profile}"
  region      = "${var.aws_region}"
}

###################
# Notifications
#########
# Normally we should create the email subscriptions, but:
# https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html#protocols-supported
#
# Please manage the email distribution list somehwere else
resource "aws_sns_topic" "email" {
  name = "email_alarms"
}

############
# CW logs
####
locals {
  # We need to have this here 'cause we need to reference the name of the metric_transformation in the metric alarm
  mt_namespace  = "LogMetrics"
  mt_name       = "SSHSessionOpenedCount"
}

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

# Filters
# TODO: we should define more filters to identify failed attempts (ie.: if the server is being bombarded then
#       this might mean some misconfig in the security groups; or we just keep an eye in the server)
resource "aws_cloudwatch_log_metric_filter" "ssh_open" {
  name           = "ec2_ssh_access"
  pattern        = "[Mon, day, timestamp, ip, id=sshd*, msg1=*opened*]"
  log_group_name = "${aws_cloudwatch_log_group.ws_log.name}"
  metric_transformation {
    namespace = "${local.mt_namespace}"
    name      = "${local.mt_name}"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ssh_sessions" {
  alarm_name                = "ssh_session_opened"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  namespace                 = "${local.mt_namespace}"
  metric_name               = "${local.mt_name}"
  period                    = "10"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors the SSH sessions opened"
  treat_missing_data        = "notBreaching"
  alarm_actions             = [
    "${aws_sns_topic.email.arn}"
  ]
}

##############
# IAM stuff
#######
data "aws_iam_policy_document" "role_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "log_agent" {
  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream"
    ]
    resources = [
      "${aws_cloudwatch_log_group.ws_log.arn}",
    ]
  }
}

resource "aws_iam_role" "ws_role" {
  name               = "ws-role"
  assume_role_policy = "${data.aws_iam_policy_document.role_trust.json}"
}

resource "aws_iam_policy" "cw_logs" {
  name   = "cw_logs_policy"
  policy = "${data.aws_iam_policy_document.log_agent.json}"
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.ws_role.name}"
  policy_arn = "${aws_iam_policy.cw_logs.arn}"
}

resource "aws_iam_instance_profile" "ws_log" {
  name = "ws_log_instance_profile"
  role = "${aws_iam_role.ws_role.name}"
}