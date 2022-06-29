output "security_group_id" {
  description = "Bastion host security group id."
  value       = aws_security_group.bastion.id
}

output "public_ip" {
  description = "Bastion host public ip."
  value       = aws_eip.bastion.public_ip
}
