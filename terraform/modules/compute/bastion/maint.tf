# IAMロール (SSM用)
resource "aws_iam_role" "this" {
  name = "${var.name_prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# SSMに必要なポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# インスタンスプロファイル
resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}-profile"
  role = aws_iam_role.this.name
}

# 最新のAmazon Linux 2023 AMIを取得
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# テスト用EC2本体
resource "aws_ec2_instance_connect_endpoint" "this" { # オプション：SSMがダメな時の保険
  count     = var.enable_connect_endpoint ? 1 : 0
  subnet_id = var.subnet_id
}

resource "aws_instance" "this" {
  ami                  = data.aws_ami.al2023.id
  instance_type        = "t3.micro"
  subnet_id            = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.this.name

  # クラスターSGを指定することで環境を模倣
  vpc_security_group_ids = var.security_group_ids

  # パブリックIPは持たせない
  associate_public_ip_address = false

  tags = {
    Name = "${var.name_prefix}-debug-instance"
  }
}