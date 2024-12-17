#!/bin/bash

# 检查是否提供了镜像参数
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <镜像名称>[:<标签>]"
    echo "例如: $0 nginx:1.25.3"
    echo "例如: $0 ddsderek/xiaoya-emd:latest"
    exit 1
fi

# 阿里云镜像仓库配置,自行配置
ALIYUN_REGISTRY="registry.cn-hangzhou.aliyuncs.com"
ALIYUN_NAME_SPACE="abcdefg"

# 获取原始镜像名
ORIGINAL_IMAGE="$1"

# 获取当前系统架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        platform_prefix=""
#        platform_prefix="linux_amd64_"
        ;;
    aarch64)
        platform_prefix="linux_arm64_"
        ;;
    armv7l)
        platform_prefix="linux_arm_v7_"
        ;;
    *)
        platform_prefix=""
        ;;
esac

# 获取镜像名:版本号
image_name_tag=$(echo "$ORIGINAL_IMAGE" | awk -F'/' '{print $NF}')

# 获取命名空间
name_space=$(echo "$ORIGINAL_IMAGE" | awk -F'/' '{if (NF==3) print $2; else if (NF==2) print $1; else print ""}')

# 获取镜像名
image_name=$(echo "$image_name_tag" | awk -F':' '{print $1}')

# 设置命名空间前缀
name_space_prefix=""
if [[ -n "${name_space}" ]]; then
    name_space_prefix="${name_space}_"
fi

# 构建阿里云镜像名
ALIYUN_IMAGE="$ALIYUN_REGISTRY/$ALIYUN_NAME_SPACE/$platform_prefix$name_space_prefix$image_name_tag"

echo "开始拉取镜像..."
echo "当前系统架构: $ARCH"
echo "阿里云镜像: $ALIYUN_IMAGE"
echo "目标镜像: $ORIGINAL_IMAGE"

# 拉取并重命名镜像
docker pull $ALIYUN_IMAGE && \
docker tag $ALIYUN_IMAGE $ORIGINAL_IMAGE && \
docker rmi $ALIYUN_IMAGE

echo "完成！镜像已准备就绪: $ORIGINAL_IMAGE" 
