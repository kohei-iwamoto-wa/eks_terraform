variable "cluster_subnet_ids" {
  description = "EKSクラスターに使用するサブネットIDのリスト"
  type        = list(string)
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster-example"
}

variable "vpc_id" {
  description = "EKSクラスターに使用するVPC ID"
  type    = string
}

variable "bastion_iam_role_arn" {
  description = "踏み台インスタンス用のIAMロールのARN"
  type        = string
  
}

variable "security_group_ids" {
  type = list(string)
}