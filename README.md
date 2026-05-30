# EKS Terraform & Kustomize Project

Terraform を使用して AWS 上に Amazon EKS（Elastic Kubernetes Service）クラスターを構築し、Kustomize を用いてアプリケーション（Nginx）を環境別に管理・デプロイするためのリポジトリです。

## ディレクトリ構造

本プロジェクトは、インフラ定義を行う `terraform` ディレクトリと、Kubernetes マニフェストを管理する `kustomize` ディレクトリに分かれています。

```text
.
├── README.md
├── terraform/          # EKS, VPC などの AWS インフラ定義 (Terraform)
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── kustomize/          # Kubernetes マニフェスト管理 (Kustomize)
    ├── base/           # 共通の基本マニフェスト (Nginx Deployment 等)
    │   └── kustomization.yaml
    └── overlays/       # 環境別の差異を定義するマニフェスト
        ├── deployment/ # 開発・検証環境用 (Namespace: deployment)
        │   └── kustomization.yaml
        └── production/ # 本番環境用
            └── kustomization.yaml
```

## 事前準備

このプロジェクトを実行するには、作業環境に以下のツールがインストールされ、適切に設定されている必要があります。

- Terraform (v1.5.0 以上推奨)
- AWS CLI (適切に IAM 権限が設定されたプロファイル)
- kubectl (v1.36.1 以上確認済み)


## インフラ構築

```
cd terraform/

# ワークスペースの初期化
terraform init

# 実行計画の確認
terraform plan

# インフラの構築（完了まで10〜15分ほどかかります）
terraform apply
```

## クラスターへの接続設定 (kubeconfig)

```
aws eks update-kubeconfig --name <CLUSTER_NAME> --region <REGION>

# 接続確認（ノードが Ready 状態であることを確認）
kubectl get nodes
```

## アプリケーションのデプロイ

### 検証環境

```
cd ../kustomize/

# マニフェストのビルド確認（反映される予定の YAML をプレビュー）
kubectl kustomize ./overlays/deployment/

# クラスターへ適用
kubectl apply -k ./overlays/deployment/
```

### 本番環境

```
# クラスターへ適用
kubectl apply -k ./overlays/production/
```

## リソースの削除

```
# 1. Kubernetes 上のリソースを削除
kubectl delete -k kustomize/overlays/deployment/

# 2. AWS インフラの削除
cd terraform/
terraform destroy
```


### 踏み台サーバーにログイン
aws ssm start-session --target i-xxxxxxxx   --region ap-northeast-1