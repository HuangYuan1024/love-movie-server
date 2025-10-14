script
#!/usr/bin/env bash
set -e

# 1. 集群如果不存在就创建
if ! k3d cluster list | grep -q "^love\s"; then
  echo "Creating k3d cluster 'love'..."
  k3d cluster create love --agents 1 -p "80:80@loadbalancer"
  echo "Cluster 'love' created successfully"
else
  echo "Cluster 'love' already exists"
fi

# 2. 安装/升级 Helm 发布
echo "Installing/upgrading Helm release 'love-movie'..."
helm upgrade --install love-movie ../../helm/love-movie \
  -f ../../helm/love-movie/values-local.yaml \
  --create-namespace --namespace love
echo "Helm release 'love-movie' installed/upgraded successfully"
