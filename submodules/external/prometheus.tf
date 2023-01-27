# resource "aws_cloudwatch_log_group" "example" {
#   name = "example"
# }

resource "aws_prometheus_workspace" "this" {
  alias = var.deploy_id
  # logging_configuration {
  #   log_group_arn = "${aws_cloudwatch_log_group.example.arn}:*"
  # }
}
