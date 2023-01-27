resource "random_password" "docdb_password" {
  length  = 16
  special = false
}

resource "aws_docdb_subnet_group" "this" {
  name       = "${var.deploy_id}-docdb"
  subnet_ids = var.subnet_ids
}

resource "aws_docdb_cluster" "this" {
  cluster_identifier           = var.deploy_id
  engine                       = "docdb"
  availability_zones           = var.availability_zones
  master_username              = var.docdb.master_username
  master_password              = random_password.docdb_password.result
  backup_retention_period      = var.docdb.backup_retention_period
  preferred_backup_window      = var.docdb.backup_window
  preferred_maintenance_window = var.docdb.maintenance_window

  enabled_cloudwatch_logs_exports = ["audit", "profiler"]

  db_subnet_group_name = aws_docdb_subnet_group.this.name

  vpc_security_group_ids = [aws_security_group.external.id]

  storage_encrypted = true
  # kms_key_id = ???

  deletion_protection = var.docdb.deletion_protection
  skip_final_snapshot = true

  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.this.name
}

resource "aws_docdb_cluster_parameter_group" "this" {
  family      = "docdb4.0"
  name        = var.deploy_id

  # TODO
  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_docdb_cluster_instance" "this" {
  for_each           = toset(var.availability_zones)
  availability_zone  = each.value
  identifier_prefix  = "${var.deploy_id}-${each.value}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.docdb.instance_class

  preferred_maintenance_window = var.docdb.maintenance_window
  # performance_insights_kms_key_id = ???
}
