# Wayland + KDE Plasma 下配置 Electron QQ 使用 fcitx5 输入法

## 问题描述

在 Wayland + KDE Plasma 环境下，Electron QQ 应用无法正常使用 fcitx5 输入中文。

## 根本原因

Electron 应用（包括 linuxqq）需要以下环境变量才能正确识别并使用 fcitx5 输入法：
- `GTK_IM_MODULE=fcitx5` - GTK 应用使用
- `QT_IM_MODULE=fcitx5` - Qt 应用使用
- `XMODIFIERS=@im=fcitx` - 备用兼容性设置
- `INPUT_METHOD=fcitx` - 输入法标识

即使在 Wayland 环境下有 `fcitx5-wayland` 支持，仍然需要显式设置这些变量。

## 环境检查清单

在应用之前，确保以下环境已就绪：

```bash
# 1. 检查 fcitx5 安装
which fcitx5
fcitx5 --version

# 2. 检查 Wayland 会话
echo $XDG_SESSION_TYPE  # 应输出: wayland

# 3. 检查必要的包
pacman -Q | grep -i fcitx
# 应包含:
# - fcitx5
# - fcitx5-gtk
# - fcitx5-qt
# - fcitx5-chinese-addons

# 4. 检查 fcitx5 进程
ps aux | grep fcitx5 | grep -v grep
```

## 解决方案

### **推荐方案：通过 Desktop Entry 配置（最简洁）**

#### 第一步：复制系统 QQ 桌面文件到用户目录

```bash
mkdir -p ~/.local/share/applications
cp /usr/share/applications/qq.desktop ~/.local/share/applications/qq.desktop
```

#### 第二步：修改用户级桌面文件

编辑 `~/.local/share/applications/qq.desktop`，将 `Exec` 行修改为：

```desktop
Exec=env GTK_IM_MODULE=fcitx5 QT_IM_MODULE=fcitx5 XMODIFIERS=@im=fcitx INPUT_METHOD=fcitx /opt/QQ/qq %U
```

修改后的完整文件内容：

```desktop
[Desktop Entry]
Name=QQ
Exec=env GTK_IM_MODULE=fcitx5 QT_IM_MODULE=fcitx5 XMODIFIERS=@im=fcitx INPUT_METHOD=fcitx /opt/QQ/qq %U
Terminal=false
Type=Application
Icon=qq
StartupWMClass=QQ
Categories=Network;
Comment=QQ
```

#### 第三步：刷新应用缓存

```bash
update-desktop-database ~/.local/share/applications/
```

#### 第四步：验证配置

在 KDE Plasma 应用启动器中搜索并启动 QQ，测试 fcitx5 输入法是否生效。

---

### **可选方案 A：创建包装脚本**

如果不想修改桌面文件，可以创建一个包装脚本：

#### 第一步：创建包装脚本

```bash
mkdir -p ~/.local/bin
cat > ~/.local/bin/linuxqq-fcitx << 'EOF'
#!/bin/bash

# Wayland + KDE Plasma 下的 fcitx5 配置
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx

# 启动真实的 QQ 应用
exec /opt/QQ/qq "$@"
EOF
chmod +x ~/.local/bin/linuxqq-fcitx
```

#### 第二步：创建对应的桌面文件

```bash
cat > ~/.local/share/applications/qq.desktop << 'EOF'
[Desktop Entry]
Name=QQ
Exec=~/.local/bin/linuxqq-fcitx %U
Terminal=false
Type=Application
Icon=qq
StartupWMClass=QQ
Categories=Network;
Comment=QQ
EOF
```

#### 第三步：刷新应用缓存

```bash
update-desktop-database ~/.local/share/applications/
```

---

### **可选方案 B：全局环境变量（不推荐）**

如果希望在全局范围内配置，可以编辑 shell 配置文件（`~/.bashrc`、`~/.zshrc` 或 `~/.profile`）：

```bash
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx
```

**缺点**：会影响所有应用，可能导致不兼容问题。

---

## 使用 KDE Plasma 启动 QQ

配置完成后，有以下几种启动方式：

### 方式 1：应用启动器（推荐）
1. 打开 KDE 应用启动器（Ctrl+空格 或 点击应用菜单）
2. 搜索 "QQ"
3. 点击启动

### 方式 2：命令行
```bash
# 如果使用推荐方案
kstart5 qq

# 或直接运行（如果使用方案 A）
~/.local/bin/linuxqq-fcitx
```

### 方式 3：系统快捷键
可在 KDE 设置中为应用创建快捷键。

---

## 验证和故障排查

### 验证 fcitx5 是否正常工作

1. **检查 fcitx5 守护进程**
   ```bash
   ps aux | grep fcitx5 | grep -v grep
   ```
   应该能看到 `/usr/bin/fcitx5` 进程运行。

2. **在 QQ 中测试输入**
   - 打开 QQ 消息窗口
   - 按 Ctrl+空格 激活 fcitx5（或配置的快捷键）
   - 尝试输入中文，应该能看到输入法候选框

3. **查看 fcitx5 日志**
   ```bash
   journalctl --user -u fcitx5 -n 50
   ```

### 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|--------|
| QQ 启动后无法切换输入法 | 环境变量未生效 | 检查桌面文件是否正确修改，重启 Plasma |
| fcitx5 无法加载 | fcitx5 进程未运行 | `systemctl --user restart fcitx5` |
| 输入法候选框不显示 | Wayland 兼容性问题 | 检查是否安装了 `fcitx5-wayland` |
| 应用菜单中看不到修改 | 缓存未更新 | 运行 `update-desktop-database ~/.local/share/applications/` |

---

## 技术说明

### 为什么需要这些环境变量？

- **Electron 框架限制**：Electron 应用基于 Chromium，需要明确的 IM 模块环境变量来加载输入法库
- **Wayland 差异**：Wayland 不使用 X11 的 XMODIFIERS，但保留这个变量有助于兼容性
- **多 IM 支持**：fcitx5 和其他输入法（ibus、fcitx 等）需要通过这些变量区分

### 为什么用户级配置优于全局配置？

1. **隔离性**：仅影响 QQ，不会导致其他应用 IM 问题
2. **可维护性**：系统更新时不会被覆盖
3. **灵活性**：可针对不同应用设置不同配置

---

## 参考资源

- [fcitx5 官方文档](https://fcitx-im.org/)
- [Electron 输入法支持](https://www.electronjs.org/docs/tutorial/offscreen-rendering)
- [KDE Plasma Desktop Entry 规范](https://specifications.freedesktop.org/desktop-entry-spec/latest/)

---

## 配置历史

- **2025-12-12**：初始文档，记录 Wayland + KDE Plasma 环境下 fcitx5 配置方案
