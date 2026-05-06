terraform {
  backend "s3" {
    bucket         = "terraform-state-730335414536-us-west-2"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    use_lockfile = true
  }
}