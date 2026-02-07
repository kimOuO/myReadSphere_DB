# myReadSphere PostgreSQL Database

完整的 Docker PostgreSQL + pgAdmin 环境，符合 myReadSphere 数据架构规范。

## 📋 目录结构

```
DB/
├── README.md                          # 主文档（本文件）
├── Readsphere_Data_Schema.md          # 数据架构规范文档
│
├── docker-compose.yml                 # Docker Compose 配置
├── init-db.sql                        # 数据库初始化 SQL 脚本
├── pgadmin-init.sh                    # pgAdmin 自动配置脚本
│
├── .env                               # 环境变量配置（不提交到 Git）
├── .env.example                       # 环境变量模板
├── .gitignore                         # Git 忽略文件
│
├── INSTALL_DOCKER.md                  # Docker 安装指南
├── PGADMIN_MANUAL_SETUP.md            # pgAdmin 手动设置指南
│
└── deprecated/                        # 已过期文件
    ├── pgadmin-pgpass.deprecated
    └── pgadmin-servers.json.deprecated
```

## 🚀 快速启动

> **前提条件**: 确保已安装 Docker 和 Docker Compose（如未安装请参考 [INSTALL_DOCKER.md](INSTALL_DOCKER.md)）

### 步骤 0: 确认必要文件（首次 clone 项目）

如果你是首次从 Git clone 这个项目，请确认以下文件存在：

✅ **必需文件**:
- `init-db.sql` - 数据库初始化脚本（应该已包含在 Git 中）
- `docker-compose.yml` - Docker 配置文件
- `(prompt)Readsphere_Data_Schema.md` - 数据架构文档

如果 `init-db.sql` 缺失，说明被 `.gitignore` 忽略了。你需要：
1. 从团队成员获取这个文件，或
2. 根据 `(prompt)Readsphere_Data_Schema.md` 重新生成

### 步骤 1: 进入 DB 目录

```bash
cd /home/mitlab/book_agent_llm/DB
```

### 步骤 2: 配置环境变量（可选）

如果使用默认配置，可以跳过此步骤直接启动。

如需自定义配置：
```bash
cp .env.example .env
nano .env  # 或使用其他编辑器修改配置
```

### 步骤 3: 启动 PostgreSQL 和 pgAdmin

```bash
docker-compose up -d
```

等待 10-15 秒让服务完全启动。

### 步骤 4: 验证服务状态

```bash
docker-compose ps
```

应该看到两个服务都处于 `Up` 状态。

### 步骤 5: 访问 pgAdmin

1. 打开浏览器访问：**http://localhost:5050**

2. 使用以下凭据登录：
   - **邮箱**: `user1@pgadmin.com`
   - **密码**: `12345`

3. 登录后，在左侧 **"Servers"** 下应该会看到 **"ReadSphere Database"**

4. 点击服务器时会提示输入密码：
   - **密码**: `12345`
   - ✓ 勾选 **"Save Password"**

5. 连接成功！现在可以查看数据库、表和数据了。

### 默认连接信息

| 服务 | 地址 | 凭据 |
|------|------|------|
| **PostgreSQL** | `localhost:5432` | 用户: `user1`<br>密码: `12345`<br>数据库: `readsphere` |
| **pgAdmin** | http://localhost:5050 | 邮箱: `user1@pgadmin.com`<br>密码: `12345` |

## 📊 数据库架构

数据库包含 5 个核心表：

1. **users** - 用户信息（学生、教师、管理员）
2. **classes** - 班级信息
3. **books** - 书籍/文学作品
4. **class_book_access** - 班级-书籍访问权限（多对多）
5. **tracking_events** - 用户行为追踪和分析

详细架构请参考 [Readsphere_Data_Schema.md](Readsphere_Data_Schema.md)

## 🔧 常用命令

### 服务管理

```bash
# 启动服务
docker-compose up -d

# 停止服务（保留数据）
docker-compose stop

# 重启服务
docker-compose restart

# 查看运行状态
docker-compose ps

# 查看实时日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f postgres
docker-compose logs -f pgadmin

# 停止并删除容器（保留数据卷）
docker-compose down

# 完全移除（包括所有数据）⚠️
docker-compose down -v
```

### 数据库操作

```bash
# 连接到 PostgreSQL 命令行
docker-compose exec postgres psql -U user1 -d readsphere

# 查看所有表
docker-compose exec postgres psql -U user1 -d readsphere -c "\dt"

# 查询用户数据
docker-compose exec postgres psql -U user1 -d readsphere -c "SELECT * FROM users;"

# 查询表数量
docker-compose exec postgres psql -U user1 -d readsphere -c "SELECT COUNT(*) FROM users;"

# 备份数据库
docker-compose exec postgres pg_dump -U user1 readsphere > backup_$(date +%Y%m%d_%H%M%S).sql

# 恢复数据库
cat backup.sql | docker-compose exec -T postgres psql -U user1 readsphere
```

### 重置和清理

```bash
# 重置所有数据（重新初始化数据库）
cd /home/mitlab/book_agent_llm/DB
docker-compose down -v
docker-compose up -d

# 仅重启 pgAdmin（不影响数据库）
docker-compose restart pgadmin

# 清理 Docker 系统（释放空间）
docker system prune -a
```

## 🔌 应用程序连接

### 连接字符串

```
postgresql://user1:12345@localhost:5432/readsphere
```

### Node.js (pg)

```javascript
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'readsphere',
  user: 'user1',
  password: '12345'
});
```

### Python (psycopg2)

```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="readsphere",
    user="user1",
    password="12345"
)
```

## 🔐 pgAdmin 配置

pgAdmin 启动时会自动从 `.env` 文件读取配置并创建数据库连接。

如果自动连接未出现，请参考 [PGADMIN_MANUAL_SETUP.md](PGADMIN_MANUAL_SETUP.md) 手动添加。

**连接参数**:
- Host: `postgres` (容器内网络)
- Port: `5432`
- Database: `readsphere`
- Username: `user1`
- Password: `12345`

## 📝 配置说明

### 环境变量 (.env)

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `POSTGRES_DB` | 数据库名称 | `readsphere` |
| `POSTGRES_USER` | 数据库用户 | `user1` |
| `POSTGRES_PASSWORD` | 数据库密码 | `12345` |
| `POSTGRES_PORT` | PostgreSQL 端口 | `5432` |
| `PGADMIN_EMAIL` | pgAdmin 登录邮箱 | `user1@pgadmin.com` |
| `PGADMIN_PASSWORD` | pgAdmin 登录密码 | `12345` |
| `PGADMIN_PORT` | pgAdmin Web 端口 | `5050` |

### 修改配置

1. 编辑 `.env` 文件
2. 重启容器：`docker-compose restart`
3. pgAdmin 配置会自动更新

## 🛠️ 故障排除

### Docker 未安装

参考 [INSTALL_DOCKER.md](INSTALL_DOCKER.md) 安装 Docker 和 Docker Compose。

### 端口被占用

如果端口 5432 或 5050 已被占用，修改 `.env` 文件：

```bash
cp .env.example .env
nano .env
```

修改端口号：
```env
POSTGRES_PORT=5433
PGADMIN_PORT=5051
```

然后重启：
```bash
docker-compose down
docker-compose up -d
```

### 无法连接数据库

```bash
# 1. 检查容器状态
docker-compose ps

# 2. 检查 PostgreSQL 是否就绪
docker-compose exec postgres pg_isready -U user1

# 3. 查看错误日志
docker-compose logs postgres

# 4. 重启服务
docker-compose restart
```

### pgAdmin 看不到数据库连接

**方法 1: 刷新浏览器**
- 按 `Ctrl+Shift+R` 强制刷新
- 或清除浏览器缓存后重新登录

**方法 2: 重置 pgAdmin**
```bash
docker-compose down -v
docker-compose up -d
```
等待 10-15 秒后重新登录 pgAdmin。

**方法 3: 手动添加连接**

参考 [PGADMIN_MANUAL_SETUP.md](PGADMIN_MANUAL_SETUP.md) 手动添加数据库连接：

1. 在 pgAdmin 左侧 **"Servers"** 上右键
2. 选择 **"Register" → "Server"**
3. 填写连接信息：
   - **General** → Name: `ReadSphere Database`
   - **Connection** → Host: `postgres`
   - **Connection** → Port: `5432`
   - **Connection** → Username: `user1`
   - **Connection** → Password: `12345`
   - **Connection** → Database: `readsphere`
   - ✓ 勾选 **"Save password"**
4. 点击 **"Save"**

### 权限错误

如果遇到 Docker 权限问题：

```bash
# 将当前用户添加到 docker 组
sudo usermod -aG docker $USER

# 重新加载组权限
newgrp docker

# 或者注销并重新登录
```

### 查看详细日志

```bash
# 查看所有日志
docker-compose logs

# 实时跟踪日志
docker-compose logs -f

# 只看最后 50 行
docker-compose logs --tail=50

# 查看特定服务
docker-compose logs postgres
docker-compose logs pgadmin
```

## 🗂️ 示例数据

数据库初始化时会自动插入测试数据：

- **3 个用户**（学生、教师、管理员）
- **2 个班级**
- **3 本书**（Oedipus the King, The Odyssey, The Iliad）
- 班级-书籍访问权限映射
- 示例追踪事件

### 测试账号

| 邮箱 | 密码 | 角色 | CEFR 等级 |
|------|------|------|-----------|
| test@gmail.com | test12345 | student | B1 |
| teacher@gmail.com | test12345 | teacher | - |
| admin@gmail.com | test12345 | admin | - |

⚠️ **生产环境请务必修改这些密码！**

## 🔒 安全建议

1. ✅ 修改默认密码（`.env` 文件）
2. ✅ 使用强密码
3. ✅ 在应用中使用密码哈希（bcrypt/argon2）
4. ✅ 配置防火墙限制数据库访问
5. ✅ 定期备份数据
6. ✅ 不要将 `.env` 文件提交到版本控制

## 📚 相关文档

- [Readsphere_Data_Schema.md](Readsphere_Data_Schema.md) - 完整数据架构文档
- [INSTALL_DOCKER.md](INSTALL_DOCKER.md) - Docker 安装指南
- [PGADMIN_MANUAL_SETUP.md](PGADMIN_MANUAL_SETUP.md) - pgAdmin 手动配置
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)

## 📞 支持

如有问题，请参考上述文档或联系开发团队。

---

**最后更新**: 2026-01-20
