#
output "ws_log_group_arn" {
  value = "${aws_cloudwatch_log_group.ws_log.arn}"
}