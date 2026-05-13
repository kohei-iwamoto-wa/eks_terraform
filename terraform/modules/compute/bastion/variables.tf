variable "name_prefix" {
  type    = string
  default = "eks-debug"
}

variable "subnet_id" {
  type        = string
  description = "失敗しているノードと同じプライベートサブネットID"
}

variable "security_group_ids" {
  type        = list(string)
  description = "EKSクラスターSGのID (sg-0b3cf...)"
}

variable "enable_connect_endpoint" {
  type    = bool
  default = false
}