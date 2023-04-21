output "change_hash" {
  value = local.change_hash
}

output "filename" {
  value = basename(local_file.templates["k8s_presetup"].filename)
}

output "resources_directory" {
  value = local.resources_directory
}
