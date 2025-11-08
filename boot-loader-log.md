# Linux LTS 内核启动失败修复日志

## 问题描述
启动失败错误信息：
```
../systemd/src/boot/boot.c:2633@call_image_start: Error preparing initrd: Not found
```

## 根本原因
系统更新后，内核引导文件名发生变化，但 `/boot/loader/entries/` 下的配置文件未同步更新，导致引导加载器找不到 initramfs 文件。

## 修复过程

### 步骤 1：检查当前引导配置
```bash
$ cd /boot/loader/entries/
$ ls
linux-cachyos.conf  linux-cachyos-lts.conf
```

### 步骤 2：列出 /boot 中的实际文件
```bash
$ ls /boot
37a9c6018a274cefbabccd3aee337dcc      initramfs-linux-cachyos.img
amd-ucode.img			      loader
EFI				      vmlinuz-linux-cachyos
initramfs-linux-cachyos-fallback.img  vmlinuz-linux-cachyos-lts
```

**问题发现：**
- `/boot` 中存在 `vmlinuz-linux-cachyos-lts`（内核）
- 但 **缺少** `initramfs-linux-cachyos-lts.img`（initramfs 文件）
- 只有 `initramfs-linux-cachyos-fallback.img` 存在

### 步骤 3：检查错误的配置
```bash
$ cat linux-cachyos-lts.conf
title Linux Cachyos Lts
options root=UUID=4481c610-729e-432c-955f-07b64de1404f rw rootflags=subvol=/@ zswap.enabled=0 nowatchdog splash
linux /vmlinuz-linux-cachyos-lts
initrd /initramfs-linux-cachyos-lts.img
```

配置文件指向 `initramfs-linux-cachyos-lts.img`，但该文件不存在。

### 步骤 4：检查其他启动目录
```bash
$ ls /efi/EFI/Linux
ls: 无法访问 '/efi/EFI/Linux': 没有那个文件或目录
```

## 修复方案

### 问题：Preset 文件为空
执行 `mkinitcpio -p linux-cachyos-lts` 失败，原因是 `/etc/mkinitcpio.d/linux-cachyos-lts.preset` 为空。

### 步骤 1：重建 Preset 文件
```bash
$ sudo cat > /etc/mkinitcpio.d/linux-cachyos-lts.preset << 'EOF'
# mkinitcpio preset file for the 'linux-cachyos-lts' package

ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux-cachyos-lts"

PRESETS=('default' 'fallback')

#default_config="/etc/mkinitcpio.conf"
default_image="/boot/initramfs-linux-cachyos-lts.img"
#default_options=""

#fallback_config="/etc/mkinitcpio.conf"
fallback_image="/boot/initramfs-linux-cachyos-lts-fallback.img"
fallback_options="-S autodetect"
EOF
```

### 步骤 2：重新生成 initramfs
```bash
$ sudo mkinitcpio -p linux-cachyos-lts
```

### 步骤 5：重新生成后验证
```bash
$ ls /boot | grep initramfs-linux-cachyos-lts
# 应该看到：
# initramfs-linux-cachyos-lts.img
# initramfs-linux-cachyos-lts-fallback.img
```

### 步骤 6：更新引导加载器
```bash
$ sudo bootctl update
```

### 步骤 7：验证配置文件（可选优化）
更新 `linux-cachyos-lts.conf` 以包含 fallback initramfs：
```bash
$ sudo nano /boot/loader/entries/linux-cachyos-lts.conf
```

配置示例（最佳实践）：
```
title Linux Cachyos Lts
options root=UUID=4481c610-729e-432c-955f-07b64de1404f rw rootflags=subvol=/@ zswap.enabled=0 nowatchdog splash
linux /vmlinuz-linux-cachyos-lts
initrd /initramfs-linux-cachyos-lts.img
initrd /initramfs-linux-cachyos-lts-fallback.img
```

### 步骤 8：重启验证
```bash
$ sudo reboot
```


## 相关文档
- Arch Linux Wiki: https://wiki.archlinux.org/title/EFISTUB
- systemd-boot 文档：https://www.freedesktop.org/software/systemd/man/systemd-boot.html
