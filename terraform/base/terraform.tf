terraform {
  backend "s3" {
    key = "terraform/base/terraform.tfstate"
    bucket = "brent-terraform"
    region = "us-east-1"
  }
}