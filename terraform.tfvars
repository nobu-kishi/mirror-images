aws_region = "ap-northeast-1"

mirror_images = [
  {
    name             = "nginx"
    source_image_ref = "docker.io/library/nginx:1.25"
    force_delete     = true
  },
  {
    name                = "custom-app"
    source_image_ref    = "alpine:3.22.2"
    alias_tag           = "v1.0.0"
    enable_custom_build = true
  }
]
