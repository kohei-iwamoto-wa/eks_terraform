# --- EKS Cluster (Control Plane) ---
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = "1.34"

  # Managed Node Group を使うため Auto Mode は OFF (ブロックごと削除または無効化)
  # bootstrap_self_managed_addons = false はそのままでOK
  # マネージドアドオンの設定を作る必要があります。
  # アクセスエントリを使用するように認証モードを変更する
  bootstrap_self_managed_addons = false

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = var.cluster_subnet_ids
  }

  # クラスター用ポリシーがアタッチされるまで作成を待機
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

# --- Managed Node Group ---
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.cluster_subnet_ids

  # インスタンス設定
  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # ノード用ポリシーがアタッチされるまで作成を待機
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryPullOnly,
  ]
}

# --- IAM Role for Cluster (Control Plane) ---
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# --- IAM Role for Nodes (Worker Nodes) ---
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Managed Node Group に必須の 3 つのポリシー
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}