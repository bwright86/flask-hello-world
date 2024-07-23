terraform {
  backend "s3" {
    key = "terraform/full/terraform.tfstate"
    bucket = "brent-terraform"
    region = "us-east-1"
  }
}