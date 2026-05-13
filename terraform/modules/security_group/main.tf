# 1. セキュリティグループ本体の定義
resource "aws_security_group" "eks_nodes" {
  name        = "eks-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name = "eks-node-sg"
    # EKSがリソースを識別するためのタグ
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# 2. ルールの定義（アウトバウンド：全許可）
# これが今回の「パブリックIPなし」構成での生命線になります
resource "aws_security_group_rule" "nodes_outbound_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
}

# 3. ルールの定義（インバウンド：ノード間通信）
resource "aws_security_group_rule" "nodes_internal_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_nodes.id
}