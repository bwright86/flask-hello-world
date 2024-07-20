provider "aws" {
  default_tags {
    Environment = "NonProd"
    Owner       = "DevOps"
    Application = "Flask_Hello_World"
  }
}