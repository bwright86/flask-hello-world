resource "aws_ecr_repository" "current" {
  name = "flash_hello_world"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}