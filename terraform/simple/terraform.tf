terraform {
  backend "s3" {
    key = "terraform/simple/terraform.tfstate"
    bucket = "brent-terraform"
    region = "us-east-1"
  }
}