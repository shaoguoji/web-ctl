#!/bin/bash

# 部署脚本 - 在5173端口部署Vue项目
# 使用方法: ./deploy.sh

set -e  # 遇到错误时退出

echo "=== 开始部署Vue项目到5173端口 ==="

# 检查Node.js版本
echo "检查Node.js版本..."
node_version=$(node --version)
echo "当前Node.js版本: $node_version"

# 检查npm是否可用
if ! command -v npm &> /dev/null; then
    echo "错误: npm未安装或不在PATH中"
    exit 1
fi

# 清理之前的构建
echo "清理之前的构建文件..."
rm -rf dist

# 安装依赖
echo "安装项目依赖..."
npm install

# 构建项目
echo "构建项目..."
npm run build

# 检查构建是否成功
if [ ! -d "dist" ]; then
    echo "错误: 构建失败，dist目录不存在"
    exit 1
fi

echo "构建成功！"

# 启动服务器
echo "启动服务器在5173端口..."
echo "访问地址: http://localhost:5173"
echo "按 Ctrl+C 停止服务器"

# 使用Python的http.server或者Node.js的serve来启动服务器
if command -v python3 &> /dev/null; then
    echo "使用Python3启动服务器..."
    cd dist
    python3 -m http.server 5173
elif command -v python &> /dev/null; then
    echo "使用Python启动服务器..."
    cd dist
    python -m http.server 5173
elif command -v npx &> /dev/null; then
    echo "使用npx serve启动服务器..."
    npx serve dist -p 5173
else
    echo "错误: 未找到可用的HTTP服务器"
    echo "请安装Python或Node.js的serve包"
    exit 1
fi 