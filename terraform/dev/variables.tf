variable "db_master_password" {
  description = "Master password for the Aurora cluster (sensitive)"
  type        = string
  sensitive   = true
}
