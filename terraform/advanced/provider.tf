provider "aws" {
  default_tags {
    tags = {
      Environment = "NonProd"
      Application = "Flask_Hello_World"
      Owner       = "DevOps"
    }
  }
}