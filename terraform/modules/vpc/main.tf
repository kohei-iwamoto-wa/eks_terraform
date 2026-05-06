provider "aws" {
  region = "ap-northeast-1"
}

# VPCモジュールの利用 (EKS向けの標準的な設定)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # NAT Gatewayの設定 (Worker Nodeがインターネットに出るために必要)
  enable_nat_gateway = var.enabele_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  # ALB Controllerがサブネットを自動検出するためのタグ
  # public_subnet_tags = {
  #   "kubernetes.io/role/elb" = "1"
  # }

  # private_subnet_tags = {
  #   "kubernetes.io/role/internal-elb" = "1"
  # }
}