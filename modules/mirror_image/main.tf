resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "terraform_data" "mirror_push" {
  count            = var.enable_custom_build ? 0 : 1
  triggers_replace = [local.build_trigger]

  provisioner "local-exec" {
    command = format("%s/scripts/mirror_push.sh", path.root)

    environment = {
      AWS_REGION = var.aws_region
      ACCOUNT    = var.account_id
      ORIGINAL   = var.source_image_ref
      TARGET     = format("%s:%s", aws_ecr_repository.this.repository_url, local.image_tag)
    }
  }

  depends_on = [aws_ecr_repository.this]
}

resource "terraform_data" "build_push" {
  count            = var.enable_custom_build ? 1 : 0
  triggers_replace = [local.build_trigger]

  provisioner "local-exec" {
    command = format("%s/scripts/build_push.sh", path.root)
    environment = {
      AWS_REGION  = var.aws_region
      ACCOUNT     = var.account_id
      ORIGINAL    = var.source_image_ref
      TARGET      = format("%s:%s", aws_ecr_repository.this.repository_url, local.image_tag)
      CONTEXT_DIR = format("%s/custom_images/%s", path.root, local.dir_name)
    }
  }

  depends_on = [aws_ecr_repository.this]
}
