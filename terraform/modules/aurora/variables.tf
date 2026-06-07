variable "cluster_identifier" {
	description = "Identifier for the Aurora cluster"
	type        = string
	default     = "aurora-cluster"
}

variable "engine" {
	description = "Database engine"
	type        = string
	default     = "aurora-postgresql"
}

variable "engine_version" {
	description = "Engine version (optional)"
	type        = string
	default     = null
}

variable "instance_class" {
	description = "Instance class for instances"
	type        = string
	default     = "db.t3.medium"
}

variable "instance_count" {
	description = "Number of instances in the cluster"
	type        = number
	default     = 2
}

variable "database_name" {
	description = "Initial database name"
	type        = string
	default     = "mydb"
}

variable "master_username" {
	description = "Master username for the database"
	type        = string
	default     = "postgres"
}

variable "master_password" {
	description = "Master password for the database"
	type        = string
	sensitive   = true
}

variable "db_subnet_ids" {
	description = "List of subnet IDs for DB subnet group"
	type        = list(string)
	default     = []
}

variable "subnet_group_name" {
	description = "DB subnet group name"
	type        = string
	default     = "aurora-db-subnet-group"
}

variable "vpc_security_group_ids" {
	description = "Security group IDs to attach to the cluster"
	type        = list(string)
	default     = []
}

variable "backup_retention_period" {
	description = "Number of days to retain backups"
	type        = number
	default     = 7
}

variable "preferred_backup_window" {
	description = "Preferred daily time range for backups"
	type        = string
	default     = "07:00-09:00"
}

variable "publicly_accessible" {
	description = "Whether instances are publicly accessible"
	type        = bool
	default     = false
}

variable "prevent_destroy" {
	description = "Prevent accidental destroy of the cluster"
	type        = bool
	default     = true
}

variable "tags" {
	description = "Tags to apply to resources"
	type        = map(string)
	default     = {}
}
