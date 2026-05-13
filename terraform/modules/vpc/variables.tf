variable "project_name" {
  description = "project name for resource naming"
  type        = string
  default     = "eks-minimal"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "AZs to use for the subnets"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "public_subnets" {
  description = "Public subnets to create"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnets" {
  description = "Private subnets to create"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "enable_nat_gateway" {
    description = "Whether to create NAT Gateway"
    type        = bool
    default     = true
}

variable "single_nat_gateway" {
    description = "Whether to use a single NAT Gateway for all AZs (cost-saving)"
    type        = bool
    default     = false
}

variable "one_nat_gateway_per_az" {
    description = "Whether to create one NAT Gateway per AZ (for high availability)"
    type        = bool
    default     = false
}