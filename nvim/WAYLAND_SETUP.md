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
