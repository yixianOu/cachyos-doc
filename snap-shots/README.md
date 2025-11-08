# CachyOS rEFInd 快速启动配置

## 问题回答

**Q: CachyOS 官方有 rEFInd 快速启动脚本吗？**  
A: 没有。官方支持 rEFInd 但不提供快速启动自动管理脚本。

**Q: 应该用 GRUB/rEFInd/Limine？**  
A: **用 rEFInd**。轻量快速，完全支持 btrfs 快速启动。

**Q: 如何在 bootloader 选择快速启动？**  
A: 用脚本修改 `/boot/refind_linux.conf`，添加快速启动条目。

## 快速开始

### 1. 安装 rEFInd
```bash
sudo pacman -S refind
sudo refind-install
```

### 2. 运行脚本生成配置
```bash
sudo cp refind-snapshot-manager.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/refind-snapshot-manager.sh
sudo refind-snapshot-manager.sh
```

### 3. 验证配置
```bash
sudo refind-snapshot-manager.sh --validate-only
```

### 4. 重启测试
```bash
sudo reboot
# UEFI 菜单选择 rEFInd → 按 Esc 查看快速启动菜单
```

## 脚本说明

**refind-snapshot-manager.sh** - 一键生成快速启动菜单
- 扫描 `/.snapshots/*` 目录
- 自动获取系统 UUID
- 生成 `/boot/refind_linux.conf`
- 自动备份配置到 `.bak`

## 常用命令

```bash
# 查看当前配置
cat /boot/refind_linux.conf

# 验证配置有效性
sudo refind-snapshot-manager.sh --validate-only

# 恢复备份（快照启动失败时）
sudo refind-snapshot-manager.sh --restore

# 手动更新快速启动列表
sudo /usr/local/bin/refind-snapshot-manager.sh

# 查看 UUID
btrfs filesystem show /
```

## 自动更新（可选）

### 方案：systemd timer（推荐）

创建定时器文件 `/etc/systemd/system/snapshot-update.timer`：
```ini
[Unit]
Description=Update rEFInd snapshots hourly

[Timer]
OnBootSec=5min
OnUnitActiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

创建服务文件 `/etc/systemd/system/snapshot-update.service`：
```ini
[Unit]
Description=rEFInd Snapshot Manager

[Service]
Type=oneshot
ExecStart=/usr/local/bin/refind-snapshot-manager.sh
```

启用自动更新：
```bash
sudo systemctl enable --now snapshot-update.timer
sudo systemctl status snapshot-update.timer
```

查看执行日志：
```bash
sudo journalctl -u snapshot-update.service -f
```

## 故障排除

- **快速启动菜单中看不到快速启动**  
  → 运行脚本重新生成配置

- **快速启动启动失败**  
  → 检查 UUID 和子卷路径是否正确

- **想切换回 systemd-boot**  
  → `sudo pacman -R refind` 然后 `sudo bootctl install`
