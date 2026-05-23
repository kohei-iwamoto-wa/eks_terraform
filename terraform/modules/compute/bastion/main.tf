data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# -----------------------------------------------------------------
# 1. EC2インスタンス & IAM（SSM対応）モジュール
# -----------------------------------------------------------------
module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "${var.name_prefix}-instance"
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  associate_public_ip_address = false
  create_iam_instance_profile = true
  iam_role_name               = "${var.name_prefix}-ssm-role"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
}

# -----------------------------------------------------------------
# 2. SSM用 VPCエンドポイント モジュール
# -----------------------------------------------------------------
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = var.vpc_id

  # エンドポイント用のセキュリティグループを自動生成し、VPC内の通信を許可
  security_group_description = "VPC Endpoints security group"
  security_group_rules = {
    ingress_https = {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block] # VPC内部からのアクセスのみ許可
    }
  }

  # 作成するエンドポイントの定義
  endpoints = {
    ssm = {
      service             = "ssm"
      subnet_ids          = [var.subnet_id]
      private_dns_enabled = true
    },
    ssmmessages = {
      service             = "ssmmessages"
      subnet_ids          = [var.subnet_id]
      private_dns_enabled = true
    },
    ec2messages = {
      service             = "ec2messages"
      subnet_ids          = [var.subnet_id]
      private_dns_enabled = true
    }
  }
}

# -----------------------------------------------------------------
# 3. 踏み台インスタンス用の最小限のセキュリティグループ
# -----------------------------------------------------------------
resource "aws_security_group" "bastion_sg" {
  name        = "${var.name_prefix}-bastion-sg"
  vpc_id      = var.vpc_id
  description = "Security group for SSM Bastion"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}