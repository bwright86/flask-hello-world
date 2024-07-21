# Hello World

Basic stock flask hello world.

This app is wrapped in a container image for deployment in AWS.

## Scenarios

The following scenarios are based on a few different use cases:

- Simple - AWS Lightsail provides a container runtime with public IP for basic web servers (Think Wordpress sites). It is simple and straightforward, which provides good security through reduced resource usage.
- Middle - AWS ECS 

## Considerations

- Using a Terraform Wrapper, like terragrunt, could break up monolithic TF scripts across stacks, make TF modules reusable across projects, and separate configuration details away from implementation details. Not implemented here, as resiliency of app is unknown, and reusability of code is unknown.
- Naming convention uses static single region, this could be extended for multi-region use, by using a naming module like "cloudposse/label/null" to dynamically create tags and resource names.
- The following security tools could be integrated for better security posture:
  - Enabling AWS SecurityHub would centralize alerts on resource misconfiguration based on AWS security best practices. Other tools can augment this ability, like: Palo Alto Prisma, SNYK, Wiz
  - Enabling GuardDuty provides threat detection across all AWS resources, runtimes (EC2, ECS, EKS, Lamgda), and RDS. Not implemented here, to maintain free-tier usage.
  - Enabling AWS Inspector would improve vulnerability scanning on packages, builds, and runtimes. It also monitors for unintended network exposure.
  - Enabling AWS CodeGuru Security/Reviewer would provide SAST code scanning for issues. If code is built in CodeBuild pipelines or stored in CodeCommit repositories.
  - Operationalizing these tools to Developers and their IDE's make vulnerability/hardening easier while code is still fresh in development.
