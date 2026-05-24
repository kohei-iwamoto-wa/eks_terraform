data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_iam_policy" "bastion_eks_describe" {
  name        = "${var.name_prefix}-bastion-eks-describe"
  description = "Policy for Bastion to describe EKS cluster for kubeconfig"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "*"
      }
    ]
  })
}

module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name                        = "${var.name_prefix}-instance"
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false
  create_iam_instance_profile = true
  iam_role_name               = "${var.name_prefix}-ssm-role"
  
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    EKSDescribeClusterPolicy     = aws_iam_policy.bastion_eks_describe.arn
  }
  
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-sg"
  description = "VPC Endpoints security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = var.vpc_id

  endpoints = {
    ssm = {
      service             = "ssm"
      subnet_ids          = [var.subnet_id]
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
    },
    ssmmessages = {
      service             = "ssmmessages"
      subnet_ids          = [var.subnet_id]
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
    },
    ec2messages = {
      service             = "ec2messages"
      subnet_ids          = [var.subnet_id]
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
    }
  }
}

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