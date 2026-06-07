terraform {
  backend "s3" {
    bucket         = "バケット名"
    key            = "stateファイルのパス"
    region         = "リージョン"
    encrypt        = true
    use_lockfile = true
  }
}