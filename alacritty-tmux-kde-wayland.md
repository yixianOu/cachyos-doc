# Arch Linux Wayland (KDE) 下使用 tmux 管理 Alacritty 简单配置文档

日期: 2025-11-09

## 1. 安装
```bash
sudo pacman -S alacritty tmux
```

## 2. 启动主会话（推荐一条命令）
```bash
alacritty -e tmux new-session -A -s main
# -A 复用已有会话；-s main 指定名称
```

## 3. tmux 配置 (~/.tmux.conf)
```tmux
# 真彩 / Terminfo
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",alacritty:RGB"
# 如果 tmux-256color 不存在：
# set -g default-terminal "screen-256color"
# set -ga terminal-overrides ",alacritty:Tc"

# 基础体验
set -g mouse on
set -g set-clipboard on
set -g history-limit 200000
set -g base-index 1
setw -g pane-base-index 1
```

## 4. Alacritty 配置 (~/.config/alacritty/alacritty.toml)
```toml
[env]
TERM = "xterm-256color"

[selection]
save_to_clipboard = true

# 可选：快捷键映射到 tmux 前缀 (默认 C-b)
[[keyboard.bindings]]
key = "T"; mods = "Control|Shift"; chars = "\u0002c"      # 新建窗口
[[keyboard.bindings]]
key = "W"; mods = "Control|Shift"; chars = "\u0002x"      # 关闭窗口
[[keyboard.bindings]]
key = "H"; mods = "Control|Shift"; chars = "\u0002h"      # 焦点左
[[keyboard.bindings]]
key = "J"; mods = "Control|Shift"; chars = "\u0002j"      # 焦点下
[[keyboard.bindings]]
key = "K"; mods = "Control|Shift"; chars = "\u0002k"      # 焦点上
[[keyboard.bindings]]
key = "L"; mods = "Control|Shift"; chars = "\u0002l"      # 焦点右
```

## 5. KDE Wayland 全局快捷键
系统设置 → 快捷键 → 自定义 → 新建命令/URL：
alacritty -e tmux new-session -A -s main
建议绑定 Meta+Return。

## 6. （可选）systemd 用户服务保持会话常驻
文件: `~/.config/systemd/user/tmux@.service`
```ini
[Unit]
Description=tmux session %i
After=graphical-session.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/tmux new-session -d -s %i
ExecStop=/usr/bin/tmux kill-session -t %i
[Install]
WantedBy=default.target
```

启用与连接：

```bash
systemctl --user enable --now tmux@main.service
alacritty -e tmux attach -t main
```

## 7. 常见问题
- 真彩异常：infocmp tmux-256color 若失败，改用 screen-256color + ,alacritty:Tc。
- 剪贴板不生效：确保 tmux ≥3.2、Alacritty ≥0.13，已 set-clipboard on；必要时安装 wl-clipboard 并用插件（yank）。
- 字体不清晰：在 alacritty.toml 增加 [font] 及 size / family。

## 8. 快速验证
```bash
# 进入会话
alacritty -e tmux new -A -s main
# 测试真彩
curl -fsSL https://raw.githubusercontent.com/gnachman/iTerm2/master/tests/256color.sh | bash
```

## 9. 同步配置到 CachyOS 主机
日期: 2025-11-09T13:36:08.309Z
```bash
# 先创建远端目录再拷贝本地 tmux / alacritty / fish 配置
ssh cachyos 'mkdir -p ~/.config/{alacritty,tmux,fish/conf.d}' && \
scp -Crp ~/.tmux.conf cachyos:~/ && \
scp -Crp -r ~/.config/{alacritty,tmux} cachyos:~/.config/ && \
scp -Crp ~/.config/fish/{config.fish,fish_variables} cachyos:~/.config/fish/ && \
scp -Crp -r ~/.config/fish/conf.d/ cachyos:~/.config/fish/conf.d/
```
提示: 如不想覆盖远端 fish 的 universal 变量，去掉拷贝 fish_variables 那一段。
