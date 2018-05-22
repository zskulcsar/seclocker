#
output "ws_log_instance_profile" {
  value = "${aws_iam_instance_profile.ws_log.name}"
}