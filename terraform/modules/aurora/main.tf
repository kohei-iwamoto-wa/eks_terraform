resource "aws_db_subnet_group" "this" {
  count = length(var.db_subnet_ids) > 0 ? 1 : 0

  name       = var.subnet_group_name
  subnet_ids = var.db_subnet_ids
  tags       = var.tags
}

resource "aws_rds_cluster" "this" {
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  vpc_security_group_ids  = var.vpc_security_group_ids

  db_subnet_group_name = length(var.db_subnet_ids) > 0 ? aws_db_subnet_group.this[0].name : null

  tags = var.tags
 
  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_rds_cluster_instance" "this" {
  count               = var.instance_count
  identifier          = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = var.instance_class
  engine              = var.engine
  engine_version      = var.engine_version
  publicly_accessible = var.publicly_accessible

  tags = var.tags
}