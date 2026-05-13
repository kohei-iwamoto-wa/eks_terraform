provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "../modules/vpc"
}

module "eks" {
  source = "../modules/eks"
  cluster_subnet_ids = module.vpc.private_subnets
  cluster_name = "cluster"

  depends_on = [module.vpc]
}