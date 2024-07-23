data "terraform_remote_state" "base_infra" {
  backend = "s3"
  config = {
    bucket = "brent-terraform"
    region = "us-east-1"
    key    = "terraform/base/terraform.tfstate"
  }
}