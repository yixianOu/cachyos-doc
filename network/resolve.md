# 有线网卡连接但无法联网 - 网关问题解决方案

## 问题诊断

**当前状态：**
- 有线网卡 enp1s0 已连接，IP: 10.168.1.55/24
- **问题：** 有线连接没有配置网关，导致无法联网
- **网关地址：** 10.168.1.1（已从ARP表确认）

---

## 解决步骤

### 配置网关（3条命令）

```bash
# 1. 设置网关为 10.168.1.1
sudo nmcli connection modify "有线连接 1" ipv4.gateway 10.168.1.1

# 2. 设置DNS
sudo nmcli connection modify "有线连接 1" ipv4.dns "8.8.8.8 114.114.114.114"

# 3. 重启网络连接
sudo nmcli connection down "有线连接 1" && sudo nmcli connection up "有线连接 1"
```

---

## 验证配置

```bash
# 检查路由表（应该看到：default via 10.168.1.1 dev enp1s0）
ip route show

# 测试外网连接
ping -c 3 8.8.8.8
ping -c 3 www.baidu.com
```

---

## 注意

- 如果配置不生效，执行：`sudo systemctl restart NetworkManager`
- 路由器禁止了ping响应（这是正常的安全设置），所以ping网关会失败，但不影响联网

---

# Arch Linux 使用 paru 解决依赖问题

## 问题描述

构建软件包时遇到依赖链问题：
- `deepin-wine8-stable` 下载失败
- `spark-dwine-helper` 依赖 `deepin-wine8-stable`
- `com.163.music.spark` 依赖 `spark-dwine-helper`

## 解决方法

### 方法1：逐个安装依赖（推荐）

```bash
# 1. 先单独安装基础依赖
paru -S deepin-wine8-stable

# 2. 安装中间层依赖
paru -S spark-dwine-helper

# 3. 最后安装目标软件
paru -S com.163.music.spark
```

### 方法2：清理缓存重试

```bash
# 清理paru缓存
paru -Scc

# 清理AUR构建缓存
rm -rf ~/.cache/paru/clone/deepin-wine8-stable
rm -rf ~/.cache/paru/clone/spark-dwine-helper

# 重新尝试安装
paru -S com.163.music.spark
```

### 方法3：手动构建依赖

```bash
# 克隆并构建基础依赖
git clone https://aur.archlinux.org/deepin-wine8-stable.git
cd deepin-wine8-stable
makepkg -si

# 返回上级目录，构建下一个依赖
cd ..
git clone https://aur.archlinux.org/spark-dwine-helper.git
cd spark-dwine-helper
makepkg -si

# 最后安装目标软件
paru -S com.163.music.spark
```

### 方法4：跳过依赖检查（不推荐）

```bash
# 仅在确定依赖已安装但检测失败时使用
paru -S --nodeps spark-dwine-helper
```

## 常用 paru 命令

```bash
# 搜索软件包
paru <package-name>

# 查看软件包详细信息
paru -Si <package-name>

# 更新所有软件包（包括AUR）
paru -Syu

# 清理不需要的依赖
paru -c

# 查看构建日志
paru -Gp <package-name>
```

## 排查技巧

1. **检查网络连接**：AUR源可能需要稳定网络
2. **更新系统**：`sudo pacman -Syu` 确保系统是最新的
3. **查看构建日志**：构建失败时仔细阅读错误信息
4. **搜索替代方案**：某些包可能有 `-bin` 或 `-git` 版本
5. **查看AUR评论**：访问 aur.archlinux.org 查看其他用户的解决方案
