data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.34"

  vpc_id     = var.vpc_id
  subnet_ids = var.cluster_subnet_ids

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  authentication_mode = "API"
  enable_cluster_creator_admin_permissions = true

  cluster_security_group_additional_rules = {
    ingress_bastion_https = {
      description              = "Allow Bastion to communicate with EKS API Server"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = var.security_group_ids[0]
    }
  }

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  eks_managed_node_groups = {
    main = {
      name         = "${var.cluster_name}-node-group"
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      min_size     = 1
      max_size     = 3
      desired_size = 2
      max_unavailable = 1
    }
  }
}

resource "aws_eks_access_entry" "console_user" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "console_user_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.console_user.principal_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "root_user" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "root_user_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.root_user.principal_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "bastion" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.bastion_iam_role_arn
  type          = "STANDARD"
  depends_on = [module.eks]
}

resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.bastion_iam_role_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.bastion]
}