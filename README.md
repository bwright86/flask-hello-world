# Hello World

Basic stock flask hello world.

This app is wrapped in a container image for deployment in AWS.

## Scenarios

The following scenarios are based on a few different use cases:

- Simple - AWS Lightsail provides a container runtime with public IP for basic web apps.

    | Pro/Con | Comment |
    | ------- | ------- |
    | Pro | Reduces security risk by reducing amount of managed resources. |
    | Pro | Lightweight to use, good for POC and potentially internal tooling. |
    | Pro | Recovery is quick, failed deployments automatically roll back to previously-good version. |
    | Pro | Downtime is reduced, active deployments are not made Inactive until new deployment is finished and healthy. |
    | Pro | Resiliency is provided by multiple nodes (Not used to maintain free-tier), and load balancing. |
    | Con | Deployments require some downtime during quick cutover. Multiple Nodes and load balancing in Lightsail would provide resiliency. |
    | Con | Underlying K8 Infrastructure is managed by AWS, so no customizations are available. |

- Advanced - Full deployment with EC2, ASG, LT, ALB, ECS. Single node and single container

    | Pro/Con | Comment |
    | ------- | ------- |
    | Pro | Fully customizable, and can scale, providing control over every aspect of the application. |
    | Pro | Recovery can be quick, downtime can be reduced, resiliency can be built in, all just like Lightsails |
    | Pro | Deployment can be customized to meet the team's need. |
    | Con | Many resources are required to deploy, and full understanding is needed manage. |
    | Con | Failover/Recovery could require more steps, and could take longer to execute. |

## Considerations

- Using a Terraform Wrapper, like terragrunt, could break up monolithic TF scripts across stacks, making TF modules reusable across projects, and separate configuration details away from implementation details. Not implemented here, as resiliency of app is unknown, and reusability of code is unknown.
- Naming convention uses static single region, this could be extended for multi-region use, by using a naming module like "cloudposse/label/null" to dynamically create tags and resource names.
- VPCs provide security and control over resources and how they communicate. Care needs to be exercised around public subnets and IGW's, as this exposes resources to the internet. I would recommend splitting the SG's between Internet <-> ALB <-> EC2, but for now the ALB is in public subnet w/ IGW, and EC2 is in Private Subnet.
- ECS is running on single node, and ALB's are running in 2 AZs. For better resiliency, spreading this across more AZ's and more nodes would reduce failure.
- AWS's Well-Architected Tool could be used to review architecture and provide insight into best practices. This was not covered here, as it was a simpler app and built as a POC.
- Terraform lock.hcl files provide "version pinning" of modules. It can be good practice to version control these in SCM to maintain consistent deployments, but it presents a layer of maintenance to upgrade and validate new versions periodically.
- The following security tools could be integrated for better security posture:
  - Enabling AWS SecurityHub would centralize alerts on resource misconfiguration based on AWS security best practices. Other tools can augment this ability, like: Palo Alto Prisma, SNYK, Wiz
  - Enabling GuardDuty provides threat detection across all AWS resources, runtimes (EC2, ECS, EKS, Lamgda), and RDS. Not implemented here, to maintain free-tier usage.
  - Enabling AWS Inspector would improve vulnerability scanning on packages, builds, and runtimes. It also monitors for unintended network exposure.
  - Enabling AWS CodeGuru Security/Reviewer would provide SAST code scanning for issues. If code is built in CodeBuild pipelines or stored in CodeCommit repositories.
  - Operationalizing these tools to Developers and their IDE's would make vulnerability/hardening easier while code is still fresh in development.


## Steps To Implement

In this section, there will be steps for configuring and building the following environments.

### Prereqs

- An empty AWS Account
- An SSO role for login, or Access Keys to an IAM User
- Terraform installed (Targeting v1.5.5)


### Base

This section will build the AWS Resources that are needed for the other scenarios. Run this first.

1. Navigate to `/terraform/base/`
2. Run `terraform init --var-file nonprod.tfvars`
3. Run `terraform apply --var-file nonprod.tfvars`
4. Confirm it creates: ECR, and VPC/Subnets/Routes/SG's/NACL's
5. Tag and push your docker image to the ECR, with:
    ```
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWSAccount>.dkr.ecr.us-east-1.amazonaws.com
    docker tag flask-hello-world:latest <AWSAccount>.dkr.ecr.us-east-1.amazonaws.com/ecr_use1_flask_hello_world:1.0
    docker push <AWSAccount>.dkr.ecr.us-east-1.amazonaws.com/ecr_use1_flask_hello_world:1.0
    ```
6. Congratulations! You have built the base infrastructure resources that is needed to build additional layers.

### Simple

This section will build on top of the base infra, and deploy a Lightsail Container service for the web app.

1. Navigate to `/terraform/simple`
2. Run `terraform init --var-file nonprod.tfvars`
3. Run `terraform apply --var-file nonprod.tfvars`
4. Confirm it creates: Lightsail Container service, deployment version, and ECR policy.
5. Navigate to [Lightsail Console](https://lightsail.aws.amazon.com/ls/webapp/home/containers), and confirm it is running.
6. Find the public endpoint, and navigate to it from your browser.
7. Congratulations! You have deployed a Lightsail container, and confirmed it works.


### Advanced

This section will build on top of the base infra, and deploy all resources for ECS to run and deploy a container.

1. Navigate to `/terraform/advanced`
2. Run `terraform init --var-file nonprod.tfvars`
3. Run `terraform apply --var-file nonprod.tfvars`
4. Confirm it creates: Launch Template, Auto Scaling Group, App Load Balancer/target group/listener, ECS cluster/capacity provider(s)/service/task definition.
5. Navigate to [ALB Console](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#LoadBalancers), and confirm it is running/healthy.
6. Find the DNS Name Info, and navigate to it from your browser.
7. Congratulations! You have deployed a EC2-based ECS cluster w/ a container, and it uses an ALB and VPC to expose portions of it to the internet.
