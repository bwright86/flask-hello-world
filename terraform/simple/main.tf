resource "aws_lightsail_container_service" "current" {
  name = replace("lcs-use1-${lower(var.resources["application_name"])}", "_", "-")
  power = "micro"
  scale = 1
  is_disabled = false

  private_registry_access {
    ecr_image_puller_role {
      is_active = true
    }
  }

  tags = var.tags
}

resource "aws_ecr_repository_policy" "default" {
  repository = data.terraform_remote_state.base_infra.outputs.ecr_repository_name
  policy = data.aws_iam_policy_document.lts_ecr_access.json
}

resource "aws_lightsail_container_service_deployment_version" "current" {
  
  container {
    container_name = replace("lcs-use1-${lower(var.resources["application_name"])}", "_", "-")
    image = "${data.terraform_remote_state.base_infra.outputs.application_image_name}:${var.resources["application_version"]}"
  
    command = []

    environment = {}
    ports = {
      5000 = "HTTP"
    }
  }

  public_endpoint {
    container_name = replace("lcs-use1-${lower(var.resources["application_name"])}", "_", "-")
    container_port = 5000

    health_check {
    #   healthy_threshold = 2
    #   unhealthy_threshold = 2
    #   timeout_seconds = 2
    #   interval_seconds = 5
      path = "/"
      success_codes = "200-499"
    }
  }

  service_name = aws_lightsail_container_service.current.name
}