# 远程目录自动挂载配置指南

## 系统信息
- **用户**: orician
- **系统**: Linux with BTRFS
- **SSHFS**: 已安装 (version 3.7.3)
- **远程服务器**: 239, 67, 155

## 当前 SSH 配置
已配置的远程主机（位于 `~/.ssh/config`）：
- **239**: 10.168.1.239 (使用密钥认证)
- **67**: 10.168.1.67 (使用密钥认证)
- **155**: 10.168.1.155 (使用密钥认证)

---

## 1. 创建挂载点目录

```bash
mkdir -p ~/remote/239/home ~/remote/239/data ~/remote/239/data2
mkdir -p ~/remote/67/home ~/remote/67/data
mkdir -p ~/remote/155/home ~/remote/155/data
```

---

## 2. 配置开机自动挂载（推荐方法：systemd 用户服务）

### 创建 systemd 服务文件

```bash
mkdir -p ~/.config/systemd/user

# 创建所有挂载服务
cat > ~/.config/systemd/user/remote-239-home.service << 'EOF'
[Unit]
Description=SSHFS Mount 239 Home
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStart=/usr/bin/sshfs 239:/home/ouyixian %h/remote/239/home -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3
ExecStop=/usr/bin/fusermount3 -u %h/remote/239/home
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

cat > ~/.config/systemd/user/remote-239-data.service << 'EOF'
[Unit]
Description=SSHFS Mount 239 Data
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStart=/usr/bin/sshfs 239:/data %h/remote/239/data -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3
ExecStop=/usr/bin/fusermount3 -u %h/remote/239/data
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

cat > ~/.config/systemd/user/remote-239-data2.service << 'EOF'
[Unit]
Description=SSHFS Mount 239 Data2
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStart=/usr/bin/sshfs 239:/data2 %h/remote/239/data2 -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3
ExecStop=/usr/bin/fusermount3 -u %h/remote/239/data2
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

cat > ~/.config/systemd/user/remote-67-home.service << 'EOF'
[Unit]
Description=SSHFS Mount 67 Home
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStart=/usr/bin/sshfs 67:/home/ouyixian %h/remote/67/home -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3
ExecStop=/usr/bin/fusermount3 -u %h/remote/67/home
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

cat > ~/.config/systemd/user/remote-67-data.service << 'EOF'
[Unit]
Description=SSHFS Mount 67 Data
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStart=/usr/bin/sshfs 67:/data %h/remote/67/data -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3
ExecStop=/usr/bin/fusermount3 -u %h/remote/67/data
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

cat > ~/.config/systemd/user/remote-155-home.service << 'EOF'
[Unit]
Description=SSHFS Mount 155 Home
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStart=/usr/bin/sshfs 155:/home/ouyixian %h/remote/155/home -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3
ExecStop=/usr/bin/fusermount3 -u %h/remote/155/home
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

cat > ~/.config/systemd/user/remote-155-data.service << 'EOF'
[Unit]
Description=SSHFS Mount 155 Data
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStart=/usr/bin/sshfs 155:/data %h/remote/155/data -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3
ExecStop=/usr/bin/fusermount3 -u %h/remote/155/data
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF
```

### 启用并启动服务

```bash
# 重载配置
systemctl --user daemon-reload

# 启用开机自动启动
systemctl --user enable remote-239-home.service remote-239-data.service remote-239-data2.service
systemctl --user enable remote-67-home.service remote-67-data.service
systemctl --user enable remote-155-home.service remote-155-data.service

# 立即启动
systemctl --user start remote-239-home.service remote-239-data.service remote-239-data2.service
systemctl --user start remote-67-home.service remote-67-data.service
systemctl --user start remote-155-home.service remote-155-data.service

# 启用用户服务持久化（允许登录前启动）
sudo loginctl enable-linger orician
```

---

## 3. 备选方案：使用 /etc/fstab

如果需要系统级挂载，编辑 `/etc/fstab` 添加：

```bash
sudo tee -a /etc/fstab << 'EOF'

# 远程 SSHFS 挂载
239:/home/ouyixian  /home/orician/remote/239/home  fuse.sshfs  defaults,_netdev,user,idmap=user,identityfile=/home/orician/.ssh/id_ed25519,allow_other,reconnect,ServerAliveInterval=15  0  0
239:/data           /home/orician/remote/239/data  fuse.sshfs  defaults,_netdev,user,idmap=user,identityfile=/home/orician/.ssh/id_ed25519,allow_other,reconnect,ServerAliveInterval=15  0  0
239:/data2          /home/orician/remote/239/data2 fuse.sshfs  defaults,_netdev,user,idmap=user,identityfile=/home/orician/.ssh/id_ed25519,allow_other,reconnect,ServerAliveInterval=15  0  0
67:/home/ouyixian   /home/orician/remote/67/home   fuse.sshfs  defaults,_netdev,user,idmap=user,identityfile=/home/orician/.ssh/id_ed25519,allow_other,reconnect,ServerAliveInterval=15  0  0
67:/data            /home/orician/remote/67/data   fuse.sshfs  defaults,_netdev,user,idmap=user,identityfile=/home/orician/.ssh/id_ed25519,allow_other,reconnect,ServerAliveInterval=15  0  0
155:/home/ouyixian  /home/orician/remote/155/home  fuse.sshfs  defaults,_netdev,user,idmap=user,identityfile=/home/orician/.ssh/id_ed25519,allow_other,reconnect,ServerAliveInterval=15  0  0
155:/data           /home/orician/remote/155/data  fuse.sshfs  defaults,_netdev,user,idmap=user,identityfile=/home/orician/.ssh/id_ed25519,allow_other,reconnect,ServerAliveInterval=15  0  0
EOF

# 测试配置
sudo mount -a
```

---

## 4. 验证和管理

### 查看挂载状态
```bash
df -h | grep remote
systemctl --user status remote-*.service
```

### 管理服务
```bash
# 查看所有远程挂载服务
systemctl --user list-units 'remote-*' --all

# 停止某个挂载
systemctl --user stop remote-239-home.service

# 重启某个挂载
systemctl --user restart remote-239-home.service

# 查看日志
journalctl --user -u remote-239-home.service -f
```

### 手动挂载/卸载
```bash
# 手动挂载
sshfs 239:/home/ouyixian ~/remote/239/home

# 手动卸载
fusermount3 -u ~/remote/239/home
```

---

## 5. 故障排查

```bash
# 测试 SSH 连接
ssh 239 "echo OK"
ssh 67 "echo OK"
ssh 155 "echo OK"

# 强制卸载卡住的挂载
fusermount3 -uz ~/remote/239/home

# 查看详细日志
journalctl --user -u remote-239-home.service --since today
```

---

**创建时间**: 2025-11-07  
**用户**: orician  
**推荐**: 使用 systemd 方式（用户级，无需 root）
