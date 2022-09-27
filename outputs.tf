output "ssh_bastion_command" {
  description = "Command to ssh into the bastion host"
  value       = "ssh -i ${local.ssh_pvt_key_path} -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no ${local.bastion_user}@${module.bastion[0].public_ip}"
}

output "k8s_tunnel_command" {
  description = "Command to run the k8s tunnel mallory."
  value       = module.k8s_setup.k8s_tunnel_command
}

output "hostname" {
  description = "Domino instance URL."
  value       = "${var.deploy_id}.${var.route53_hosted_zone_name}"
}

output "efs_volume_handle" {
  description = "EFS volume handle <filesystem id id>::<accesspoint id>"
  value       = module.storage.efs_volume_handle
}

output "efs_access_point_id" {
  description = "EFS access_point id"
  value       = module.storage.efs_access_point_id
}

output "efs_file_system_id" {
  description = "EFS filesystem id"
  value       = module.storage.efs_file_system_id
}

output "region" {
  description = "Deployment region."
  value       = var.region
}

output "deploy_id" {
  description = "Deployment ID."
  value       = var.deploy_id
}

output "s3_buckets" {
  description = "S3 buckets name,arn."
  value       = module.storage.s3_buckets
}

output "key_pair_name" {
  description = "SSH key pair name."
  value       = aws_key_pair.domino.key_name
}
