#!/bin/bash

set -e

echo "🚀 开始部署 Love Movie 微服务套件..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请启动Docker"
    exit 1
fi

# 检查是否已经有运行中的容器
echo "📦 检查现有容器..."
RUNNING_CONTAINERS=$(docker ps -q --filter "name=love_movie_")
if [ -n "$RUNNING_CONTAINERS" ]; then
    echo "🛑 停止现有容器..."
    docker stop $RUNNING_CONTAINERS
fi

# 拉取基础镜像
echo "📥 拉取所需镜像..."
docker pull mysql:9.1 || echo "⚠️  使用本地MySQL镜像"
docker pull nacos/nacos-server:v3.0.3 || echo "⚠️  使用本地Nacos镜像"

# 构建user-service镜像
echo "🔨 构建 user-service 镜像..."
docker build -t love-movie/user-service:latest -f ../../docker/user-service/Dockerfile ../../../

# 启动所有服务
echo "🎯 启动所有服务..."
docker-compose up -d mysql redis minio nacos user-service

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 15

# 验证 Nacos 配置 - 使用更可靠的验证方法
echo "🔍 验证 Nacos 配置..."
echo "检查 Nacos 配置文件内容:"
docker exec love_movie_nacos cat /home/nacos/conf/application.properties || echo "无法读取配置文件"

# 多种方式验证配置
CONFIG_CHECK1=$(docker exec love_movie_nacos grep -q "nacos.core.api.compatibility.console.enabled=true" /home/nacos/conf/application.properties 2>/dev/null && echo "found" || echo "not found")
CONFIG_CHECK2=$(docker exec love_movie_nacos cat /home/nacos/conf/application.properties 2>/dev/null | grep -q "nacos.core.api.compatibility.console.enabled=true" && echo "found" || echo "not found")

# 检查 server.address 配置
SERVER_ADDRESS_CHECK=$(docker exec love_movie_nacos grep -q "server.address=0.0.0.0" /home/nacos/conf/application.properties 2>/dev/null && echo "found" || echo "not found")

echo "配置检查结果:"
echo "方式1: $CONFIG_CHECK1"
echo "方式2: $CONFIG_CHECK2"
echo "server.address 检查: $SERVER_ADDRESS_CHECK"

if [ "$CONFIG_CHECK1" = "found" ] || [ "$CONFIG_CHECK2" = "found" ]; then
    echo "✅ Nacos 兼容性配置验证成功"
else
    echo "❌ Nacos 兼容性配置验证失败，尝试直接写入容器..."

    # 直接写入容器
    docker exec love_movie_nacos sh -c 'echo "nacos.core.api.compatibility.console.enabled=true" >> /home/nacos/conf/application.properties'

    # 重启 Nacos 使配置生效
    echo "重启 Nacos 容器..."
    docker restart love_movie_nacos

    # 等待 Nacos 重启
    echo "等待 Nacos 重启..."
    for i in {1..30}; do
        if curl -f http://localhost:8848/nacos/ > /dev/null 2>&1; then
            echo "✅ Nacos 重启成功"
            break
        fi
        echo "⏱️  等待 Nacos 启动... ($i/30)"
        sleep 2
    done

    # 最终验证
    if docker exec love_movie_nacos grep -q "nacos.core.api.compatibility.console.enabled=true" /home/nacos/conf/application.properties 2>/dev/null; then
        echo "✅ Nacos 兼容性配置最终验证成功"
    else
        echo "❌ Nacos 兼容性配置仍然失败，但继续部署..."
    fi
fi

# 验证 server.address 配置
if [ "$SERVER_ADDRESS_CHECK" = "found" ]; then
    echo "✅ server.address 配置为 0.0.0.0 验证成功"
else
    echo "❌ server.address 配置验证失败，尝试直接写入容器..."

    # 直接写入容器
    docker exec love_movie_nacos sh -c 'echo "server.address=0.0.0.0" >> /home/nacos/conf/application.properties'

    # 重启 Nacos 使配置生效
    echo "重启 Nacos 容器..."
    docker restart love_movie_nacos

    # 等待 Nacos 重启
    echo "等待 Nacos 重启..."
    for i in {1..30}; do
        if curl -f http://localhost:8848/nacos/ > /dev/null 2>&1; then
            echo "✅ Nacos 重启成功"
            break
        fi
        echo "⏱️  等待 Nacos 启动... ($i/30)"
        sleep 2
    done

    # 最终验证
    if docker exec love_movie_nacos grep -q "server.address=0.0.0.0" /home/nacos/conf/application.properties 2>/dev/null; then
        echo "✅ server.address 配置最终验证成功"
    else
        echo "❌ server.address 配置仍然失败，但继续部署..."
    fi
fi

# 使用Higress官方脚本安装Higress
echo "🔧 安装 Higress..."

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# 指定Higress安装目录
HIGRESS_INSTALL_DIR="$PROJECT_ROOT/higress"
echo "Higress 安装目录: $HIGRESS_INSTALL_DIR"

## 创建安装目录
#mkdir -p "$HIGRESS_INSTALL_DIR"
#
## 进入安装目录执行安装命令
#cd ../../../
#
## 清理可能存在的旧安装
#echo "🧹 清理可能存在的旧 Higress 安装..."
#docker ps -a --filter "name=higress" --format "{{.Names}}" | xargs -r docker rm -f
#docker network ls --filter "name=higress" --format "{{.Name}}" | xargs -r docker network rm 2>/dev/null || true
#
## 下载并执行Higress安装脚本
#echo "从GitHub 下载 Higress 安装脚本..."
## 用宿主的Docker网络
#curl -fsSL https://higress.io/standalone/get-higress.sh | bash -s -- -c "nacos://host.docker.internal:8848" -a;
#echo "✅ Higress 安装成功"

# 由于官方脚本会创建自己的容器，我们需要调整网络配置
echo "🌐 配置网络连接..."
sleep 15

echo "当前网络列表:"
docker network ls | grep app

# 将Higress网关容器加入到app-network网络
HIGRESS_CONTAINER=$(docker ps --filter "name=higress-gateway" --format "{{.Names}}" | head -1)
if [ -n "$HIGRESS_CONTAINER" ]; then
    echo "连接 Higress 容器 ($HIGRESS_CONTAINER) 到网络app-network..."
    docker network connect local_app-network "$HIGRESS_CONTAINER" 2>/dev/null || echo "⚠️  网络连接已存在或连接失败"
else
    echo "⚠️  未找到 Higress 容器，跳过网络连接"
fi

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

echo "✅ 部署完成！"
echo ""
echo "📊 服务访问地址："
echo "   - Nacos 控制台: http://localhost:8181/ (账号: nacos/nacos)"
echo "   - Higress 控制台: http://localhost:8080 (账号: admin/admin)"
echo "   - MySQL: localhost:3306 (root/root)"
echo "   - Higress Gateway: http://localhost:80"
echo ""
echo "🔧 常用命令："
echo "   - 查看日志: docker-compose logs -f"
echo "   - 停止服务: docker-compose down"
echo "   - 重启服务: docker-compose restart"
echo "   - 查看Higress状态: cd $HIGRESS_INSTALL_DIR && bin/status.sh"
echo "   - Higress安装目录: $HIGRESS_INSTALL_DIR"