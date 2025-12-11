# SSH 隧道速查

## 三种场景

### 1. 本地转发（访问远程）⭐
```bash
ssh -fN -L 本地端口:目标:端口 主机
ssh -fN -L 3307:localhost:3306 239          # 远程 MySQL
ssh -fN -L 3307:10.168.1.100:3306 239       # 跳板访问
```

### 2. 远程转发（暴露本地）
```bash
ssh -fN -R 远程端口:本地:端口 主机
ssh -fN -R 9000:localhost:8080 239          # 远程访问本地
```

### 3. SOCKS 代理
```bash
ssh -fN -D 1080 239                         # 浏览器设 SOCKS5: 127.0.0.1:1080
```

---

## SSH Config 配置（推荐）

`~/.ssh/config`：

```bash
Host gitlab
    HostName 10.168.1.155
    User ouyixian
    LocalForward 2080 localhost:2080
    IdentityFile ~/.ssh/id_ed25519

Host 239-all
    HostName 10.168.1.239
    User ouyixian
    LocalForward 3307 localhost:3306
    LocalForward 6380 localhost:6379
    LocalForward 8081 localhost:8080
    ServerAliveInterval 60
    IdentityFile ~/.ssh/id_ed25519

Host 239-proxy
    HostName 10.168.1.239
    User ouyixian
    DynamicForward 1080
    IdentityFile ~/.ssh/id_ed25519
```

使用：`ssh -fN 239-mysql`

---

## 开机自启

```bash
cat > ~/.config/systemd/user/ssh-tunnel-239.service << 'EOF'
[Unit]
Description=SSH Tunnel to 239
After=network-online.target

[Service]
ExecStart=/usr/bin/ssh -N -L 3307:localhost:3306 239
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl --user enable --now ssh-tunnel-239.service
```

---

## 管理

```bash
# 查看
ps aux | grep "ssh -"
ss -tlnp | grep ssh

# 关闭
pkill -f "ssh.*3307"
```

---

## 参数说明

- `-L` 本地转发
- `-R` 远程转发
- `-D` SOCKS 代理
- `-f` 后台运行
- `-N` 不执行命令
- `-g` 允许局域网访问
- `-C` 压缩传输
