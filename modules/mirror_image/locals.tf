locals {
  image_tag = coalesce(var.alias_tag, split(":", var.source_image_ref)[1])
  dir_name  = replace(var.name, "-", "_")

  build_trigger = sha1(jsonencode({
    repository     = aws_ecr_repository.this.repository_url
    image_tag      = local.image_tag
    dockerfile_md5 = var.enable_custom_build ? filemd5(format("%s/custom_images/%s/Dockerfile", path.root, local.dir_name)) : ""
  }))
}
