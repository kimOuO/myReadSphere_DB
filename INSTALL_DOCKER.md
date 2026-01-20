# ⚠️ 文档说明

**此文档包含 Docker 安装步骤，如果已安装 Docker 请参考主文档：[README.md](README.md)**

---

# Docker 安装指南

## 方法 1: 使用 apt 安装 Docker

```bash
# 更新包索引
sudo apt-get update

# 安装必要的依赖
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 添加 Docker 官方 GPG 密钥
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 设置稳定版仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 将当前用户添加到 docker 组（避免每次都用 sudo）
sudo usermod -aG docker $USER

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker
```

安装完成后，**注销并重新登录**或执行：
```bash
newgrp docker
```

## 方法 2: 如果 Docker 已安装但未运行

```bash
# 启动 Docker 服务
sudo systemctl start docker

# 检查 Docker 状态
sudo systemctl status docker

# 将用户添加到 docker 组
sudo usermod -aG docker $USER
newgrp docker
```

## 验证安装

```bash
# 检查 Docker 版本
docker --version

# 检查 Docker Compose 版本
docker compose version

# 运行测试容器
docker run hello-world
```

## 启动 PostgreSQL 和 pgAdmin

安装完成后，运行：

```bash
cd /home/mitlab/book_agent_llm/DB

# 启动服务
docker compose up -d

# 查看运行状态
docker compose ps

# 查看日志
docker compose logs -f
```

## 访问服务

- **PostgreSQL**: localhost:5432
  - 用户名: `user1`
  - 密码: `12345`
  - 数据库: `readsphere`

- **pgAdmin**: http://localhost:5050
  - 邮箱: `user1@pgadmin.com`
  - 密码: `12345`

## 在 pgAdmin 中连接数据库

1. 打开浏览器访问 http://localhost:5050
2. 使用 pgAdmin 凭据登录
3. 右键点击 "Servers" → "Register" → "Server"
4. 在 "General" 标签中:
   - Name: `ReadSphere DB`
5. 在 "Connection" 标签中:
   - Host: `postgres` (容器名称，不是 localhost)
   - Port: `5432`
   - Username: `user1`
   - Password: `12345`
   - Database: `readsphere`
6. 点击 "Save"

## 常用命令

```bash
# 停止服务
docker compose stop

# 启动服务
docker compose start

# 重启服务
docker compose restart

# 查看日志
docker compose logs -f postgres
docker compose logs -f pgadmin

# 进入 PostgreSQL 容器
docker compose exec postgres psql -U user1 -d readsphere

# 完全删除服务和数据
docker compose down -v
```
