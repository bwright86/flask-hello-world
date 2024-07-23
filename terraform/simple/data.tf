data "terraform_remote_state" "base_infra" {
  backend = "s3"
  config = {
    bucket = "brent-terraform"
    region = "us-east-1"
    key    = "terraform/base/terraform.tfstate"
  }
}

data "aws_iam_policy_document" "lts_ecr_access" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [aws_lightsail_container_service.current.private_registry_access[0].ecr_image_puller_role[0].principal_arn]
    }

    actions = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchCheckLayerAvailability"
    ]
  }
}