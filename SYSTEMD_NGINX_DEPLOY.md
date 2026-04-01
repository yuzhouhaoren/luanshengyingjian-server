# systemd + Nginx 部署指南

## 项目配置检查

项目已经配置完成，包含以下关键文件：

- **nginx.conf** - Nginx反向代理配置（已配置 /home/admin/projects 路径）
- **deploy.sh** - 自动化部署脚本（已配置 /home/admin/projects 路径）
- **backend/app.py** - 已更新CORS配置
- **frontend/src/config/api.js** - 已配置相对路径API

## 服务器操作步骤

### 1. 登录服务器

```bash
# 使用SSH登录服务器
ssh root@101.133.238.8
```

### 2. 创建目录并克隆项目

```bash
# 创建 /home/admin 目录（如果不存在）
sudo mkdir -p /home/admin
sudo chown admin:admin /home/admin

# 切换到 admin 用户
su - admin

# 创建项目目录
mkdir -p /home/admin/projects

# 克隆项目
cd /home/admin/projects
git clone https://github.com/yuzhouhaoren/luanshengyingjian-server .

# 给脚本添加执行权限
chmod +x deploy.sh
```

### 3. 执行部署脚本

```bash
# 执行部署脚本
./deploy.sh
```

### 4. 手动部署步骤（如果脚本执行失败）

#### 4.1 安装依赖

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv nginx nodejs npm
```

#### 4.2 配置后端

```bash
cd /home/admin/projects/backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn
```

#### 4.3 创建systemd服务文件

创建文件 `/etc/systemd/system/dating-app-backend.service`：

```ini
[Unit]
Description=Dating App Backend
After=network.target

[Service]
Type=simple
User=admin
WorkingDirectory=/home/admin/projects/backend
Environment="PATH=/home/admin/projects/backend/venv/bin"
ExecStart=/home/admin/projects/backend/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 app:app
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

#### 4.4 构建前端

```bash
cd /home/admin/projects/frontend
npm install
npm run build
```

#### 4.5 配置Nginx

```bash
sudo cp /home/admin/projects/nginx.conf /etc/nginx/sites-available/dating-app
sudo ln -sf /etc/nginx/sites-available/dating-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

#### 4.6 启动后端服务

```bash
sudo systemctl daemon-reload
sudo systemctl enable dating-app-backend
sudo systemctl start dating-app-backend
```

## 常用管理命令

### 后端服务管理

```bash
# 查看服务状态
sudo systemctl status dating-app-backend

# 启动服务
sudo systemctl start dating-app-backend

# 停止服务
sudo systemctl stop dating-app-backend

# 重启服务
sudo systemctl restart dating-app-backend

# 查看日志
sudo journalctl -u dating-app-backend -f

# 查看最近50条日志
sudo journalctl -u dating-app-backend -n 50
```

### Nginx管理

```bash
# 查看Nginx状态
sudo systemctl status nginx

# 启动Nginx
sudo systemctl start nginx

# 停止Nginx
sudo systemctl stop nginx

# 重启Nginx
sudo systemctl restart nginx

# 测试Nginx配置
sudo nginx -t

# 查看Nginx错误日志
sudo tail -f /var/log/nginx/error.log

# 查看Nginx访问日志
sudo tail -f /var/log/nginx/access.log
```

## 目录结构

```
/home/admin/projects/
├── backend/              # Flask后端
│   ├── app.py           # 主应用文件
│   ├── requirements.txt # Python依赖
│   ├── dating.db        # SQLite数据库
│   ├── avatars/         # 头像存储目录
│   └── venv/            # Python虚拟环境
├── frontend/            # Vue前端
│   ├── dist/           # 构建后的静态文件
│   ├── src/            # 源代码
│   └── package.json    # Node依赖
├── nginx.conf          # Nginx配置
└── deploy.sh           # 部署脚本
```

## 故障排查

### 后端服务无法启动

```bash
# 检查日志
sudo journalctl -u dating-app-backend -n 50

# 手动测试后端
cd /home/admin/projects/backend && source venv/bin/activate && python app.py
```

### Nginx 502错误

```bash
# 检查后端是否运行
sudo systemctl status dating-app-backend

# 检查端口监听
sudo netstat -tlnp | grep 5000

# 检查Nginx错误日志
sudo tail -f /var/log/nginx/error.log
```

### 前端显示空白

```bash
# 检查前端构建文件
ls -la /home/admin/projects/frontend/dist/

# 重新构建前端
cd /home/admin/projects/frontend
npm run build

# 检查Nginx配置
cat /etc/nginx/sites-available/dating-app
```

### API调用失败

```bash
# 检查CORS配置
cat /home/admin/projects/backend/app.py | grep -A 5 -B 5 CORS

# 检查前端API配置
cat /home/admin/projects/frontend/src/config/api.js

# 测试API直接访问
curl http://localhost:5000/api/health
```

## 安全配置

### 1. 配置防火墙

```bash
# 安装ufw
sudo apt-get install -y ufw

# 允许80和22端口
sudo ufw allow 80/tcp
sudo ufw allow 22/tcp

# 启用防火墙
sudo ufw enable

# 查看状态
sudo ufw status
```

### 2. 配置HTTPS（推荐）

使用Let's Encrypt获取免费SSL证书：

```bash
# 安装certbot
sudo apt-get install -y certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d 101.133.238.8

# 自动续期
sudo certbot renew --dry-run
```

### 3. 定期备份

创建备份脚本 `backup.sh`：

```bash
#!/bin/bash

BACKUP_DIR="/home/admin/backup/dating-app"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p $BACKUP_DIR

# 备份数据库
cp /home/admin/projects/backend/dating.db $BACKUP_DIR/dating_${DATE}.db

# 备份头像
zip -r $BACKUP_DIR/avatars_${DATE}.zip /home/admin/projects/backend/avatars/

echo "备份完成: $BACKUP_DIR"
```

## 性能优化

### 1. Gunicorn配置

编辑 `dating-app-backend.service` 文件，调整worker数量：

```ini
# 根据服务器CPU核心数调整worker数量
# 一般为 (CPU核心数 * 2) + 1
ExecStart=/home/admin/projects/backend/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 app:app
```

### 2. Nginx缓存配置

在 `nginx.conf` 中添加缓存配置：

```nginx
# 缓存配置
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=100m inactive=60m;

# 在location /api/中添加
proxy_cache my_cache;
proxy_cache_valid 200 302 5m;
proxy_cache_valid 404 1m;
```

### 3. 数据库优化

对于SQLite数据库，定期执行VACUUM：

```bash
# 进入后端目录
cd /home/admin/projects/backend

# 执行VACUUM
sqlite3 dating.db "VACUUM;"
```
