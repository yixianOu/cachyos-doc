# Neovim + LazyVim 快速指南

Archlinux + Wayland + Alacritty + Zellij + Fish 环境配置。

## 快速开始

启动 Neovim（首次启动自动安装插件）：
```fish
nvim
```

## 快捷键

| 快捷键 | 说明 |
|--------|------|
| `<C-\>` | 打开浮动终端 |
| `<leader>tt` | 切换终端 |
| `<leader>tf` | 浮动终端 |
| `<leader>th` | 水平分割终端 |
| `<leader>tv` | 垂直分割终端 |
| `<C-h/j/k/l>` (终端内) | 窗口间导航 |
| `<Esc>` (终端内) | 返回 Normal 模式 |

## Zellij + Alacritty 集成启动

**问题**: `alacritty -e zellij -s main` 启动后立即闪退

**原因**: 旧的 "main" 会话处于 EXITED 状态，新建窗口尝试连接已死进程导致立即关闭

**推荐启动命令**（一键启动）：
```bash
zellij kill-session main 2>/dev/null; alacritty -e zellij -s main &
```

或添加到 `~/.config/fish/config.fish`：
```fish
alias zellij-start="zellij kill-session main 2>/dev/null; alacritty -e zellij -s main &"
```

然后按 `Alt+F2` 或设置快捷键调用 `zellij-start`

## Fish Shell 配置

在 `~/.config/fish/config.fish` 中添加：

```fish
# Neovim
set -gx EDITOR nvim
set -gx VISUAL nvim

```

## 常见命令

```fish
:terminal       # 打开终端
:Lazy          # 打开插件管理器
:Lazy sync     # 同步插件
:Lazy update   # 更新插件
```

## 包含的插件

- **LazyVim**: IDE 配置框架
- **toggleterm.nvim**: 终端管理
- **nvim-lspconfig**: LSP 支持
- **nvim-treesitter**: 语法高亮
- **telescope.nvim**: 模糊查找
