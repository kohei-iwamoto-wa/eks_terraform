data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.34"

  # ネットワーク設定
  vpc_id     = var.vpc_id
  subnet_ids = var.cluster_subnet_ids

  # クラスターエンドポイントのアクセス設定
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  authentication_mode = "API"

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    # aws-ebs-csi-driver = {
    #   most_recent              = true
    #   attach_ind_component_policy = true 
    # }
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