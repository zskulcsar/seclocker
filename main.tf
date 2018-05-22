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