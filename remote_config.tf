provider "aws" {
  version    = "~> 1.21"
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
}
provider "null" {}
# UNFORTUNATELY THIS MUST BE HARDCODED
terraform {
  backend "s3" {
    bucket = "A-BUCKET-YOU-ALREADY-CREATED"
    key    = "states/project/terraform.tfstate"
    region = "us-west-2"
  }
}
