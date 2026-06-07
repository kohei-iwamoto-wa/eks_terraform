provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "../modules/vpc"
}

module "eks" {
  source = "../modules/eks"
  vpc_id = module.vpc.vpc_id
  security_group_ids = [module.ec2_bastion.security_group_id]
  cluster_subnet_ids = module.vpc.private_subnets
  bastion_iam_role_arn = module.ec2_bastion.bastion_iam_role_arn
  cluster_name = "cluster"
  depends_on = [module.vpc]
}

module "ec2_bastion" {
  source = "../modules/compute/bastion"
  subnet_id = module.vpc.private_subnets[0]
  security_group_ids = []
  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr
}