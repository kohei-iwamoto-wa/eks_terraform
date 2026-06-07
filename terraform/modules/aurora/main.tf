resource "aws_aurora_cluster" "postgresql" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-postgresql"
  availability_zones      = ["apnortheast-1a", "apnortheast-1b", "apnortheast-1c"]
  database_name           = "mydb"
  master_username         = "admin"
  master_password         = "must_be_eight_characters"
  backup_retention_period = 2
  preferred_backup_window = "07:00-09:00"
}