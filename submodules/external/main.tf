resource "aws_security_group" "external" {
  name        = "${var.deploy_id}-external"
  description = "External security group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = "${var.deploy_id}-external"
  }
}
