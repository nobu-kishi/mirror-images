module "mirror_images" {
  source   = "./modules/mirror_image"
  for_each = { for image in var.mirror_images : image.name => image }

  account_id          = data.aws_caller_identity.current.account_id
  aws_region          = var.aws_region
  name                = each.value.name
  enable_custom_build = each.value.enable_custom_build
  source_image_ref    = each.value.source_image_ref
  force_delete        = each.value.force_delete
  alias_tag           = each.value.alias_tag
}
