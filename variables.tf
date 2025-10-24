variable "aws_region" {
  description = "AWS プロバイダーと ECR リポジトリで使用する AWS リージョン"
  type        = string
}

variable "mirror_images" {
  description = "ミラー/ビルド構成のリスト。各エントリには一意の name が必要"
  type = list(object({
    name                = string
    source_image_ref    = string
    alias_tag           = optional(string, null)
    force_delete        = optional(bool, false)
    enable_custom_build = optional(bool, false)
  }))
  default = []
}
