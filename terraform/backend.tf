terraform {
  backend "s3" {
    bucket = "supergoon-terraform-plans"
    key    = "supergoon-dash"
    region = "us-east-2"
  }
}