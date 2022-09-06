output "efs_volume_handle" {
  description = "EFS volume handle <filesystem id>::<accesspoint id>"
  value       = "${aws_efs_access_point.eks.file_system_id}::${aws_efs_access_point.eks.id}"
}

output "efs_access_point_id" {
  description = "EFS access_point id"
  value       = aws_efs_access_point.eks.id
}

output "efs_file_system_id" {
  description = "EFS filesystem id"
  value       = aws_efs_file_system.eks.id
}

output "monitoring_s3_bucket_arn" {
  description = "Monitoring bucket arn"
  value       = aws_s3_bucket.backups.arn
}

output "s3_buckets" {
  description = "S3 buckets name and arn"
  value = [for b in local.s3_buckets : {
    "bucket_name" = b.bucket_name,
    "arn"         = b.arn
  }]
}
