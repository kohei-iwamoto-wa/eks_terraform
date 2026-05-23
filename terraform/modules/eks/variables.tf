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