output "application_tag" {
    value = aws_servicecatalogappregistry_application.current.application_tag
}

output "ecr_repository_name" {
    value = aws_ecr_repository.current.name
}

output "application_image_name" {
    value = aws_ecr_repository.current.repository_url
}