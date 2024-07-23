output "ecr_repository_name" {
    value = aws_ecr_repository.current.name
}

output "application_image_name" {
    value = aws_ecr_repository.current.repository_url
}

output "vpc_id" {
    value = module.vpc.vpc_id
}

output "vpc_default_sg_id" {
    value = module.vpc.default_security_group_id
}

output "vpc_private_subnets" {
    value = module.vpc.private_subnets
}

output "vpc_public_subnets" {
    value = module.vpc.public_subnets
}

output "ecs_task_execution_role_arn" {
    value = aws_iam_role.ecs_task_execution_role.arn
}

output "ec2_runtime_role_arn" {
    value = aws_iam_role.ec2_runtime.arn
}

output "ec2_runtime_instance_profile_arn" {
    value = aws_iam_instance_profile.ec2_runtime.arn
}