#!/bin/bash

# 孪生映见 - Linux服务器部署脚本
# 公网IP: 101.133.238.8

set -e

echo "=========================================="
echo "  孪生映见 - 部署脚本"
echo "  服务器IP: 101.133.238.8"
echo "=========================================="

# 配置变量
APP_DIR="/var/www/dating-app"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/frontend"
NGINX_CONF="/etc/nginx/sites-available/dating-app"

# 1. 更新系统
echo "[1/8] 更新系统包..."
sudo apt-get update
sudo apt-get upgrade -y

# 2. 安装依赖
echo "[2/8] 安装必要依赖..."
sudo apt-get install -y python3 python3-pip python3-venv nginx nodejs npm git

# 3. 创建应用目录
echo "[3/8] 创建应用目录..."
sudo mkdir -p $APP_DIR
sudo chown -R $USER:$USER $APP_DIR

# 4. 复制项目文件
echo "[4/8] 复制项目文件..."
# 注意：请手动将项目文件上传到 $APP_DIR 目录
# 或使用 git clone/pull

# 5. 安装Python依赖并配置后端
echo "[5/8] 配置后端服务..."
cd $BACKEND_DIR
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn

# 创建后端服务文件
sudo tee /etc/systemd/system/dating-app-backend.service > /dev/null << EOF
[Unit]
Description=Dating App Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$BACKEND_DIR
Environment="PATH=$BACKEND_DIR/venv/bin"
ExecStart=$BACKEND_DIR/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 app:app
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# 6. 构建前端
echo "[6/8] 构建前端..."
cd $FRONTEND_DIR
npm install
npm run build

# 7. 配置Nginx
echo "[7/8] 配置Nginx..."
sudo cp $APP_DIR/nginx.conf $NGINX_CONF
sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# 8. 启动后端服务
echo "[8/8] 启动后端服务..."
sudo systemctl daemon-reload
sudo systemctl enable dating-app-backend
sudo systemctl start dating-app-backend

echo ""
echo "=========================================="
echo "  部署完成！"
echo "=========================================="
echo ""
echo "访问地址: http://101.133.238.8"
echo ""
echo "常用命令:"
echo "  查看后端日志: sudo journalctl -u dating-app-backend -f"
echo "  重启后端: sudo systemctl restart dating-app-backend"
echo "  重启Nginx: sudo systemctl restart nginx"
echo ""
