resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id
  tags = {
    "Name" = "${var.deploy_id}-domino-igw"
  }
}
