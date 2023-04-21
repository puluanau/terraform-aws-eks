output "change_hash" {
  description = "Hash of all templated files"
  value       = local.change_hash
}

output "filename" {
  description = "Filename of primary script"
  value       = basename(local_file.templates["k8s_presetup"].filename)
}

output "resources_directory" {
  description = "Directory for provisioned scripts and templated files"
  value       = local.resources_directory
}
