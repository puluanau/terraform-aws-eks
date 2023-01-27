resource "random_password" "rds_password" {
  length  = 16
  special = false
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.deploy_id}-rds"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  identifier = var.deploy_id

  engine         = "postgres"
  engine_version = var.rds.engine_version

  instance_class = var.rds.instance_class

  allocated_storage     = var.rds.allocated_storage
  max_allocated_storage = var.rds.max_allocated_storage
  storage_type          = "gp3"

  maintenance_window = var.rds.maintenance_window

  # monitoring_interval = ???
  # monitoring_role_arn = ???

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  deletion_protection = var.rds.deletion_protection

  storage_encrypted = true
  # kms_key_id        = aws_kms_key.vault.arn

  username = var.rds.username
  password = random_password.rds_password.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.external.id]

  multi_az            = true
  publicly_accessible = false

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = false

  copy_tags_to_snapshot = true
  skip_final_snapshot   = true

  # iam_database_authentication_enabled
}
