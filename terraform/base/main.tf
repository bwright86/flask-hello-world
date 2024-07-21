resource "aws_servicecatalogappregistry_application" "current" {
  name        = title(var.resources["application_name"])
  description = "Hello world from Python Flask"
}

resource "aws_ecr_repository" "current" {
  name = "ecr_use1_${lower(var.resources["application_name"])}"
  image_tag_mutability = "IMMUTABLE"

  # TODO: Consider enabling image scanning for vuln scanning ahead of runtime.
  # TODO: Consider Enhanced scanning is available with AWS Insepctor, which adds Package-level vuln scanning and continuous scanning.
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = aws_servicecatalogappregistry_application.current.application_tag
}