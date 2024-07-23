resource "aws_launch_template" "current" {
  name_prefix   = "ECS-template"
  image_id      = var.resources["ami_image_id"]
  instance_type = var.resources["instance_type"]

  iam_instance_profile {
    arn = data.terraform_remote_state.base_infra.outputs.ec2_runtime_instance_profile_arn
  }

  key_name               = "Brent-ec2"
  vpc_security_group_ids = [data.terraform_remote_state.base_infra.outputs.vpc_default_sg_id]

  block_device_mappings {
    device_name = "/dev/sdb"
    ebs {
      volume_size = 4
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ecs-instance"
    }
  }

  user_data = filebase64("${path.module}/ecs.sh")
}

resource "aws_autoscaling_group" "current" {
  name_prefix         = "ECS-asg"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = data.terraform_remote_state.base_infra.outputs.vpc_private_subnets

  launch_template {
    id      = aws_launch_template.current.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECS"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_lb" "current" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.base_infra.outputs.vpc_default_sg_id]
  subnets            = data.terraform_remote_state.base_infra.outputs.vpc_public_subnets
}

resource "aws_lb_target_group" "current" {
  name        = "ecs-tg"
  port        = var.resources["lb_port"]
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.base_infra.outputs.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "current" {
  load_balancer_arn = aws_lb.current.arn
  port              = var.resources["lb_port"]
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.current.arn
  }
}

resource "aws_ecs_cluster" "current" {
  name = "my-ecs-cluster"
}

resource "aws_ecs_capacity_provider" "current" {
  name = "my-ecs-capacity"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.current.arn

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "current" {
  cluster_name = aws_ecs_cluster.current.name

  capacity_providers = [aws_ecs_capacity_provider.current.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.current.name
  }
}

resource "aws_ecs_task_definition" "current" {
  family             = "my-ecs-task"
  network_mode       = "awsvpc"
  execution_role_arn = data.terraform_remote_state.base_infra.outputs.ecs_task_execution_role_arn
  cpu                = 256
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name      = var.resources["application_name"]
      image     = "${data.terraform_remote_state.base_infra.outputs.application_image_name}:${var.resources["application_version"]}"
      cpu       = 32
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = tonumber(var.resources["lb_port"])
          hostPort      = tonumber(var.resources["lb_port"])
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ECS_AVAILABLE_LOGGING_DRIVERS"
          value = "[\"json-file\",\"awslogs\"]"
        }
      ]
    }
  ])

  requires_compatibilities = []
  tags                     = {}
}

resource "aws_ecs_service" "current" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.current.id
  task_definition = aws_ecs_task_definition.current.arn
  desired_count   = 1

  network_configuration {
    subnets         = data.terraform_remote_state.base_infra.outputs.vpc_private_subnets
    security_groups = [data.terraform_remote_state.base_infra.outputs.vpc_default_sg_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.current.arn
    container_name   = var.resources["application_name"]
    container_port   = var.resources["lb_port"]
  }

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = plantimestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.current.name
    base              = 1
    weight            = 100
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [aws_autoscaling_group.current]
}
