output "bastion_iam_role_arn" {
  description = "The ARN of the IAM role created for the Bastion instance"
  value       = module.ec2_bastion.iam_role_arn
}

output "security_group_id" {
  value       = aws_security_group.bastion_sg.id
  description = "The ID of the security group"
}