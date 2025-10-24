output "repository_urls" {
  description = "論理的なミラーイメージ名をキーとしたリポジトリURL"
  value       = { for name, mod in module.mirror_images : name => mod.repository_url }
}

output "repository_arns" {
  description = "論理的なミラーイメージ名をキーとしたリポジトリARN"
  value       = { for name, mod in module.mirror_images : name => mod.repository_arn }
}

output "repository_names" {
  description = "論理的なミラーイメージ名をキーとしたリポジトリ名"
  value       = { for name, mod in module.mirror_images : name => mod.repository_name }
}
