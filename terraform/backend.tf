terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "path/to/my/key"
    region         = "ap-northeast-1"
    encrypt        = true
  }
}