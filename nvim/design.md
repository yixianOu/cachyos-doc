# Neovim 配置设计文档

基于 Archlinux + Wayland + Alacritty + Zellij + Fish 环境的 Neovim 配置方案。

---

## 1. 框架选择

**LazyVim** - Neovim 配置框架
- 官方 starter 模板
- 24K+ stars，社区活跃
- 开箱即用，生态完善
- Wayland、Alacritty、Zellij 开箱兼容

安装：
```fish
git clone https://github.com/LazyVim/starter ~/.config/nvim
cd ~/.config/nvim && rm -rf .git
```

---

## 2. 颜色主题

**Catppuccin (Mocha)**
- 柔和现代风格
- 护眼深色主题
- Wayland 原生支持
- Alacritty 完美兼容

LazyVim 内置支持，开箱即用。

---

## 3. 插件配置

### 必装插件（已内置于 LazyVim）

```lua
-- 界面
nvim-lualine/lualine.nvim          -- 状态栏
akinsho/bufferline.nvim            -- 标签栏
folke/which-key.nvim               -- 快捷键提示

-- 导航
nvim-telescope/telescope.nvim      -- 模糊查找
nvim-tree/nvim-tree.lua            -- 文件树

-- 代码编辑
hrsh7th/nvim-cmp                   -- 自动补全
L3MON4D3/LuaSnip                   -- 代码片段

-- LSP / 代码智能
neovim/nvim-lspconfig              -- LSP 配置
williamboman/mason.nvim            -- LSP 安装管理
williamboman/mason-lspconfig.nvim  -- LSP 自动配置

-- 语法高亮
nvim-treesitter/nvim-treesitter    -- 语法树

-- Git
tpope/vim-fugitive                 -- Git 命令
lewis6991/gitsigns.nvim            -- Git 符号
```

### 终端集成

在 `lua/plugins/` 目录创建 `terminal.lua`：

```lua
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
    },
  },
}
```

---

## 4. LSP 配置

### Python 和 Go

在 `lua/plugins/lsp.lua` 配置：

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Python
        pyright = {},
        
        -- Go
        gopls = {},
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP servers
        "pyright",
        "gopls",
      },
    },
  },
}
```

### 使用方式

```vim
:LspStart                    -- 启动 LSP
:LspInfo                     -- 查看 LSP 状态
gd                           -- 转到定义
gr                           -- 查看引用
K                            -- 查看文档
<leader>ca                   -- 代码操作（默认快捷键）
```

---

## 5. 快捷键

使用 LazyVim 默认快捷键，无需重新配置。

常用快捷键（默认）：

```
<leader>ff    - 查找文件
<leader>fg    - 全文搜索
<leader>e     - 打开文件树
<leader>ca    - 代码操作
<C-\>         - 浮动终端（已配置）
```

更多快捷键：`:help which-key` 或按 `<leader>?` 查看。

---

## 6. 文件结构

```
~/.config/nvim/
├── init.lua                 # 主入口（无需修改）
│
├── lua/
│   ├── config/
│   │   ├── lazy.lua         # Lazy 配置（无需修改）
│   │   ├── options.lua      # 编辑器选项（无需修改）
│   │   ├── keymaps.lua      # 快捷键（无需修改）
│   │   └── autocmds.lua     # 自动命令（无需修改）
│   │
│   └── plugins/
│       ├── example.lua      # 示例（可删除）
│       ├── terminal.lua     # 终端集成（新增）
│       └── lsp.lua          # LSP 配置（修改）
│
└── README.md
```

---

## 7. 环境变量配置

### Fish Shell (~/.config/fish/config.fish)

```fish
# Neovim
set -gx EDITOR nvim
set -gx VISUAL nvim


# 终端
set -gx TERM alacritty
```

---

## 8. 快速开始

1. **安装 LazyVim**
```fish
git clone https://github.com/LazyVim/starter ~/.config/nvim
cd ~/.config/nvim && rm -rf .git
```

2. **启动 Neovim**
```fish
nvim
```
首次启动会自动安装所有插件。

3. **配置 LSP**
编辑 `~/.config/nvim/lua/plugins/lsp.lua`，按上面的代码配置 Python 和 Go。

4. **验证配置**
```vim
:Lazy          -- 查看插件
:Lazy sync     -- 同步插件
:LspInfo       -- 查看 LSP 状态
```

---

## 9. 常见操作

### 搜索和导航

```vim
<leader>ff    - 查找文件
<leader>fg    - 全文搜索（需要 ripgrep）
<leader>e     - 文件树
/             - 当前文件搜索
```

### 代码编辑

```vim
<leader>ca    - 代码操作（重命名、提取函数等）
gd            - 转到定义
gr            - 查看引用
K             - 查看文档
<C-x><C-o>    - 补全菜单
```

### 终端

```vim
<C-\>         - 切换终端
:terminal     - 打开终端
```

---

## 10. 参考文档

- [LazyVim 官网](https://www.lazyvim.org/)
- [Neovim 文档](https://neovim.io/)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/wiki)
- [Catppuccin 主题](https://github.com/catppuccin/nvim)
