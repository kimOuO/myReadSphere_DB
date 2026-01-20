# ⚠️ 辅助文档

**此文档用于 pgAdmin 手动配置，常规使用请参考主文档：[README.md](README.md)**

---

# 手动添加数据库连接到 pgAdmin

如果自动导入没有生效，请按照以下步骤手动添加：

## 方法 1: 在 pgAdmin Web 界面手动添加

1. 打开浏览器访问：http://localhost:5050
2. 使用以下凭据登录：
   - **邮箱**: `user1@pgadmin.com`
   - **密码**: `12345`

3. 在左侧 "Servers" 上右键，选择 **"Register" → "Server..."**

4. 在弹出的对话框中填写：

### General 标签
- **Name**: `ReadSphere Database`

### Connection 标签
- **Host name/address**: `postgres`
- **Port**: `5432`
- **Maintenance database**: `readsphere`
- **Username**: `user1`
- **Password**: `12345`
- **Save password**: ✓ (勾选)

5. 点击 **Save** 保存

## 方法 2: 使用 psql 命令行连接（验证）

```bash
# 从宿主机连接
docker-compose exec postgres psql -U user1 -d readsphere

# 查看所有表
\dt

# 查看用户数据
SELECT * FROM users;

# 退出
\q
```

## 方法 3: 清除 pgAdmin 数据并重新导入

```bash
cd /home/mitlab/book_agent_llm/DB

# 完全清除包括数据卷
docker-compose down -v

# 重新启动（会自动导入配置）
docker-compose up -d

# 等待 10 秒后访问
sleep 10
```

然后重新登录 pgAdmin，服务器应该会自动出现。

## 连接信息快速参考

| 参数 | 值 |
|------|-----|
| Host | `postgres` (容器内) 或 `localhost` (宿主机) |
| Port | `5432` |
| Database | `readsphere` |
| Username | `user1` |
| Password | `12345` |

## 验证数据库正在运行

```bash
# 检查容器状态
docker-compose ps

# 测试连接
docker-compose exec postgres pg_isready -U user1

# 查看数据库列表
docker-compose exec postgres psql -U user1 -d readsphere -c "\l"

# 查看表
docker-compose exec postgres psql -U user1 -d readsphere -c "\dt"
```
