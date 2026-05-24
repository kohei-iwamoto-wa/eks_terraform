provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "../modules/vpc"
}

module "ec2_bastion" {
  source = "../modules/compute/bastion"
  subnet_id = module.vpc.private_subnets[0]
  security_group_ids = [module.eks.cluster_security_group_id]
  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr
}

# module "eks" {
#   source = "../modules/eks"
#   vpc_id = module.vpc.vpc_id
#   cluster_subnet_ids = module.vpc.private_subnets
#   cluster_name = "cluster"
#   depends_on = [module.vpc]
# }