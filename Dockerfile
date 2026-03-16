# 基础镜像
FROM python:3.9-slim

# 工作目录
WORKDIR /app

# 复制前端构建文件
COPY frontend/dist/ /app/dist/

# 复制后端文件
COPY backend/app.py /app/
COPY backend/requirements.txt /app/
COPY backend/dating.db /app/
COPY backend/avatars/ /app/avatars/

# 安装系统依赖
RUN apt-get update && apt-get install -y gcc

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 安装 gunicorn 用于生产环境运行
RUN pip install gunicorn

# 暴露端口
EXPOSE 5000

# 启动命令
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]