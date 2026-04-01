# 孪生映见 - Linux服务器部署指南

## 服务器信息
- **公网IP**: 101.133.238.8
- **部署目录**: `/var/www/dating-app`

## 部署步骤

### 1. 上传项目文件到服务器

将本地项目文件上传到服务器的 `/var/www/dating-app` 目录：

```bash
# 使用 scp 命令上传（在本地执行）
scp -r backend frontend nginx.conf deploy.sh root@101.133.238.8:/var/www/dating-app/
```

或者使用 FTP/SFTP 工具上传。

### 2. 在服务器上执行部署脚本

```bash
# SSH 登录服务器
ssh root@101.133.238.8

# 进入项目目录
cd /var/www/dating-app

# 给部署脚本添加执行权限
chmod +x deploy.sh

# 执行部署脚本
./deploy.sh
```

### 3. 手动部署（如果脚本执行失败）

#### 3.1 安装依赖
```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv nginx nodejs npm
```

#### 3.2 配置后端
```bash
cd /var/www/dating-app/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install gunicorn
```

#### 3.3 创建后端服务
创建文件 `/etc/systemd/system/dating-app-backend.service`：
```ini
[Unit]
Description=Dating App Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/dating-app/backend
Environment="PATH=/var/www/dating-app/backend/venv/bin"
ExecStart=/var/www/dating-app/backend/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl enable dating-app-backend
sudo systemctl start dating-app-backend
```

#### 3.4 构建前端
```bash
cd /var/www/dating-app/frontend
npm install
npm run build
```

#### 3.5 配置Nginx
```bash
sudo cp /var/www/dating-app/nginx.conf /etc/nginx/sites-available/dating-app
sudo ln -sf /etc/nginx/sites-available/dating-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

### 4. 验证部署

访问 http://101.133.238.8 查看应用是否正常运行。

## 常用命令

```bash
# 查看后端服务状态
sudo systemctl status dating-app-backend

# 查看后端日志
sudo journalctl -u dating-app-backend -f

# 重启后端服务
sudo systemctl restart dating-app-backend

# 重启Nginx
sudo systemctl restart nginx

# 查看Nginx状态
sudo systemctl status nginx

# 查看Nginx错误日志
sudo tail -f /var/log/nginx/error.log
```

## 文件结构

```
/var/www/dating-app/
├── backend/              # Flask后端
│   ├── app.py
│   ├── requirements.txt
│   ├── dating.db
│   ├── avatars/
│   └── venv/            # Python虚拟环境
├── frontend/            # Vue前端
│   ├── dist/           # 构建后的文件
│   ├── src/
│   └── package.json
├── nginx.conf          # Nginx配置
└── deploy.sh           # 部署脚本
```

## 安全建议

1. **配置防火墙**：只开放80、443端口
2. **配置SSL证书**：使用 Let's Encrypt 免费证书
3. **定期备份数据库**：`dating.db` 文件
4. **更新依赖**：定期更新系统包和Python/Node依赖

## 故障排查

### 后端无法启动
```bash
# 检查日志
sudo journalctl -u dating-app-backend -n 50

# 手动测试后端
cd /var/www/dating-app/backend
source venv/bin/activate
python app.py
```

### Nginx 502错误
```bash
# 检查后端是否运行
sudo systemctl status dating-app-backend

# 检查端口监听
sudo netstat -tlnp | grep 5000
```

### 前端显示空白
```bash
# 检查dist目录是否存在
ls -la /var/www/dating-app/frontend/dist/

# 重新构建前端
cd /var/www/dating-app/frontend
npm run build
```
