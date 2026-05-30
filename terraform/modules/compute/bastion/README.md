# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance


# 1. 安全に書き込みができるホームディレクトリ（~）に移動
cd ~

# 2. 再度バイナリをダウンロード（今度は成功するはずです）
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# 3. 実行権限を付与
chmod +x ./kubectl

# 4. パスの通る場所に移動（ここは sudo が必要です）
sudo mv ./kubectl /usr/local/bin/kubectl

# 5. 確認
kubectl version --client --output=yaml


## kubeconfig 作成

aws eks update-kubeconfig --region ap-northeast-1 --name cluster

