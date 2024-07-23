resource "aws_ecr_repository" "current" {
  name = "ecr_use1_${lower(var.resources["application_name"])}"
  image_tag_mutability = "IMMUTABLE"

  # TODO: Consider enabling image scanning for vuln scanning ahead of runtime.
  # TODO: Consider Enhanced scanning is available with AWS Insepctor, which adds Package-level vuln scanning and continuous scanning.
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = ">=5.0.0"
  

  name = "test"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  create_igw         = true

  manage_default_security_group = true
  default_security_group_egress = [ 
    {
      description = "Allow all egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
   ]
  default_security_group_ingress = [
    {
      description = "Allow all ingress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      self = true
     },
    {
      description = "Allow internet traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  manage_default_network_acl = true
  private_inbound_acl_rules = [
    {
      rule_number = 1
      rule_action = "deny"
      from_port   = 22
      to_port     = 22
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 2
      rule_action = "allow"
      from_port   = 3389
      to_port     = 3389
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]
  private_outbound_acl_rules = [
    {
      rule_number = 1
      rule_action = "deny"
      from_port   = 22
      to_port     = 22
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 2
      rule_action = "deny"
      from_port   = 3389
      to_port     = 3389
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_iam_role" "ec2_runtime" {
  name = "ec2-runtime"

  assume_role_policy = data.aws_iam_policy_document.ec2-runtime-trust.json

  inline_policy {
    name = "ec2-runtime-policy"
    policy = data.aws_iam_policy_document.ec2-runtime-permissions.json
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
  ]
}

resource "aws_iam_instance_profile" "ec2_runtime" {
  name = "ec2-runtime-instance-profile"
  role = aws_iam_role.ec2_runtime.name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ec2-runtime-trust.json
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}