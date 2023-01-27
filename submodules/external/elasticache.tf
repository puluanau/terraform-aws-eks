resource "random_password" "elasticache_password" {
  length  = 16
  special = false
}

resource "aws_elasticache_subnet_group" "this" {
  name       = var.deploy_id
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_cluster" "this" {
  cluster_id           = var.deploy_id
  engine               = "redis"
  node_type            = var.elasticache.node_type
  num_cache_nodes      = 1
  parameter_group_name = var.elasticache.parameter_group_name
  engine_version       = var.elasticache.engine_version
  port                 = 6379

  maintenance_window = var.elasticache.maintenance_window

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.external.id]

  snapshot_retention_limit = var.elasticache.snapshot_retention_limit
  snapshot_window          = var.elasticache.snapshot_window

  # log_delivery_configuration {
  #   destination      = aws_cloudwatch_log_group.example.name
  #   destination_type = "cloudwatch-logs"
  #   log_format       = "text"
  #   log_type         = "slow-log"
  # }
  # log_delivery_configuration {
  #   destination      = aws_kinesis_firehose_delivery_stream.example.name
  #   destination_type = "kinesis-firehose"
  #   log_format       = "json"
  #   log_type         = "engine-log"
  # }
}
