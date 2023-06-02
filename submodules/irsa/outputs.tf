output "info" {
  description = "IRSA information"
  value       = try(local.irsa_info, null)
}
