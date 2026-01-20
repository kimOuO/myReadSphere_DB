#!/bin/sh
# pgAdmin 初始化脚本 - 从环境变量生成配置文件

# 等待目录创建
mkdir -p /var/lib/pgadmin/storage

# 创建 servers.json 配置
cat > /pgadmin4/servers.json << EOF
{
  "Servers": {
    "1": {
      "Name": "ReadSphere Database",
      "Group": "Servers",
      "Host": "postgres",
      "Port": ${POSTGRES_PORT:-5432},
      "MaintenanceDB": "${POSTGRES_DB:-readsphere}",
      "Username": "${POSTGRES_USER:-user1}",
      "SSLMode": "prefer"
    }
  }
}
EOF

# 创建 pgpass 文件在 pgAdmin 数据目录
mkdir -p /var/lib/pgadmin/storage/user1_pgadmin.com
cat > /var/lib/pgadmin/storage/user1_pgadmin.com/.pgpass << EOF
postgres:${POSTGRES_PORT:-5432}:${POSTGRES_DB:-readsphere}:${POSTGRES_USER:-user1}:${POSTGRES_PASSWORD:-12345}
postgres:${POSTGRES_PORT:-5432}:*:${POSTGRES_USER:-user1}:${POSTGRES_PASSWORD:-12345}
EOF

chmod 600 /var/lib/pgadmin/storage/user1_pgadmin.com/.pgpass
chown -R 5050:5050 /var/lib/pgadmin/storage 2>/dev/null || true

# 启动 pgAdmin
exec /entrypoint.sh
