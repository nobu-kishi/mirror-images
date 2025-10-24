variable "account_id" {
  description = "ECRリポジトリが存在するAWS アカウント ID"
  type        = string
}

variable "aws_region" {
  description = "ECRリポジトリが存在するAWS リージョン"
  type        = string
}

variable "name" {
  description = "リソースの識別名"
  type        = string
}

variable "enable_custom_build" {
  description = "カスタムイメージとしてビルドするかの可否"
  type        = bool
  default     = false
}

variable "source_image_ref" {
  description = "ミラーリング対象のソースイメージ参照 (例: docker.io/library/nginx:1.25)"
  type        = string
  default     = null
}

variable "alias_tag" {
  description = "イメージに付与する任意のタグ"
  type        = string
  default     = null
}

variable "force_delete" {
  description = "ECRリポジトリを強制的に削除するかの可否"
  type        = bool
  default     = false
}
