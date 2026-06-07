output "cluster_id" {
  description = "RDS cluster identifier"
  value       = aws_rds_cluster.this.id
}

output "cluster_arn" {
  description = "RDS cluster ARN"
  value       = aws_rds_cluster.this.arn
}

output "endpoint" {
  description = "Primary writer endpoint"
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "instance_ids" {
  description = "List of instance ids in the cluster"
  value       = aws_rds_cluster_instance.this[*].id
}
