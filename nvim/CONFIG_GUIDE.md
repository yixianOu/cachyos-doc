# Neovim 配置指南

> 本文档梳理了基于 **LazyVim** + **Kickstart.nvim** 的完整 Neovim 配置体系

**更新日期**: 2025-12-14  
**配置框架**: LazyVim + Kickstart.nvim  
**插件管理**: lazy.nvim

---

## 📋 目录

- [配置文件概览](#配置文件概览)
- [加载顺序与依赖](#加载顺序与依赖)
- [详细文件说明](#详细文件说明)
- [插件系统](#插件系统)
- [快捷键速查](#快捷键速查)
- [常用命令](#常用命令)

---

## 配置文件概览

```
~/.config/nvim/
├── init.lua                          # 📌 主入口 (加载器)
└── lua/
    ├── config/                       # 📁 核心配置目录
    │   ├── options.lua              # ⚙️  编辑器选项
    │   ├── autocmds.lua             # 🔔 自动命令
    │   ├── keymaps.lua              # 🔑 快捷键
    │   ├── lazy.lua                 # 📦 插件管理器配置
    │   └── init.lua.example         # 📚 参考文件 (Kickstart)
    └── plugins/                      # 📁 插件定义目录
        ├── ui.lua                   # 🎨 UI & 导航插件
        ├── editor.lua               # ✏️  编辑器插件
        ├── conform.lua              # 🔨 代码格式化
        ├── lsp.lua                  # 🔌 LSP & 语言服务
        └── terminal.lua             # 💻 终端插件
```

| 文件 | 大小 | 作用 | 依赖 |
|-----|------|------|------|
| init.lua | 262B | 主入口，控制加载顺序 | 无 |
| config/options.lua | 1KB | 编辑器行为和外观设置 | LazyVim defaults |
| config/autocmds.lua | 692B | 自动触发事件和回调 | 无 |
| config/keymaps.lua | 935B | 键盘快捷键绑定 | 插件加载后 |
| config/lazy.lua | 1.8KB | lazy.nvim 配置 | LazyVim, plugins/* |
| plugins/ui.lua | 2KB | which-key, todo, mini | lazy.nvim |
| plugins/editor.lua | 3.3KB | telescope, treesitter, gitsigns | lazy.nvim |
| plugins/conform.lua | 756B | 代码格式化工具 | lazy.nvim |
| plugins/lsp.lua | 669B | LSP 配置和 Mason | lazy.nvim |
| plugins/terminal.lua | 238B | 终端管理 | lazy.nvim |

---

## 加载顺序与依赖

### 📊 完整加载流程

```
启动 Neovim
    ↓
init.lua (入口点)
    ↓
┌─────────────────────────────────────┐
│ 1️⃣  config/options.lua              │
│     加载编辑器选项                   │
│     (在 LazyVim 基础选项后)         │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ 2️⃣  config/autocmds.lua             │
│     注册自动命令和事件处理           │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ 3️⃣  config/lazy.lua                 │
│     初始化 lazy.nvim 插件管理器      │
│     加载所有 plugins/*.lua           │
│     ├── ui.lua                      │
│     ├── editor.lua                  │
│     ├── conform.lua                 │
│     ├── lsp.lua                     │
│     └── terminal.lua                │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ 4️⃣  config/keymaps.lua              │
│     注册快捷键                       │
│     (在所有插件加载后)              │
└─────────────────────────────────────┘
    ↓
✅ Neovim 启动完成
```

### 🔗 依赖关系图

```
init.lua
  ├─→ config/options.lua
  │    └─→ LazyVim defaults (自动加载)
  │
  ├─→ config/autocmds.lua
  │    └─→ (无依赖)
  │
  ├─→ config/lazy.lua
  │    ├─→ LazyVim/LazyVim (核心)
  │    └─→ plugins/* (5个插件文件)
  │        ├─→ ui.lua
  │        │    ├─→ which-key.nvim
  │        │    ├─→ todo-comments.nvim
  │        │    └─→ mini.nvim
  │        │
  │        ├─→ editor.lua
  │        │    ├─→ telescope.nvim
  │        │    ├─→ nvim-treesitter
  │        │    ├─→ gitsigns.nvim
  │        │    └─→ guess-indent.nvim
  │        │
  │        ├─→ conform.lua
  │        │    └─→ conform.nvim
  │        │
  │        ├─→ lsp.lua
  │        │    ├─→ nvim-lspconfig
  │        │    ├─→ mason.nvim
  │        │    └─→ fidget.nvim
  │        │
  │        └─→ terminal.lua
  │            └─→ toggleterm.nvim
  │
  └─→ config/keymaps.lua
       └─→ (依赖所有插件已加载)
```

---

## 详细文件说明

### 1️⃣ init.lua - 主入口文件

**位置**: `~/.config/nvim/init.lua`  
**作用**: 控制整个 Neovim 配置的加载顺序  
**大小**: 262B

#### 内容

```lua
-- Load options first (before plugins)
require("config.options")

-- Load autocommands
require("config.autocmds")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Load keymaps last (after plugins are loaded)
require("config.keymaps")
```

#### 关键点

| 顺序 | 模块 | 原因 |
|-----|------|------|
| 1 | options.lua | 插件加载前需要基础设置 |
| 2 | autocmds.lua | 注册事件处理 |
| 3 | lazy.lua | 加载所有插件 |
| 4 | keymaps.lua | 插件加载后再绑定键位 |

---

### 2️⃣ config/options.lua - 编辑器选项

**位置**: `~/.config/nvim/lua/config/options.lua`  
**作用**: 配置 Neovim 编辑器的行为和外观  
**继承**: LazyVim 默认选项  
**大小**: 1KB

#### 包含的选项

| 选项 | 作用 | 值 |
|-----|------|-----|
| breakindent | 换行缩进 | true |
| ignorecase | 搜索忽略大小写 | true |
| smartcase | 搜索智能大小写 | true |
| signcolumn | 显示符号列 | 'yes' |
| list | 显示隐藏字符 | true |
| listchars | 隐藏字符显示方式 | {tab='» ', trail='·', nbsp='␣'} |
| inccommand | 实时替换预览 | 'split' |
| cursorline | 显示当前行 | true |
| scrolloff | 滚动偏移行数 | 10 |
| confirm | 保存前确认 | true |

#### 代码示例

```lua
-- 启用换行缩进
vim.o.breakindent = true

-- 智能搜索：大小写敏感，除非输入全小写
vim.o.ignorecase = true
vim.o.smartcase = true

-- 始终显示符号列（用于 LSP 诊断）
vim.o.signcolumn = 'yes'

-- 显示隐藏字符
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- 实时替换预览
vim.o.inccommand = 'split'
```

---

### 3️⃣ config/autocmds.lua - 自动命令

**位置**: `~/.config/nvim/lua/config/autocmds.lua`  
**作用**: 定义自动触发的事件和回调函数  
**大小**: 692B

#### 包含的自动命令

| 事件 | 触发条件 | 作用 |
|-----|--------|------|
| TextYankPost | 复制文本后 | 高亮显示已复制区域 |

#### 代码示例

```lua
-- 复制文本时高亮显示
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
```

#### 使用方式

- 复制任何文本（如 `yap`）
- 复制的区域会短暂高亮

---

### 4️⃣ config/keymaps.lua - 快捷键绑定

**位置**: `~/.config/nvim/lua/config/keymaps.lua`  
**作用**: 定义全局快捷键  
**依赖**: 所有插件加载完毕  
**大小**: 935B

#### 包含的快捷键

| 快捷键 | 模式 | 作用 |
|-------|------|------|
| `<Esc>` | normal | 清除搜索高亮 |
| `<Esc><Esc>` | terminal | 退出终端模式 |
| `<C-h>` | normal | 聚焦左窗口 |
| `<C-j>` | normal | 聚焦下窗口 |
| `<C-k>` | normal | 聚焦上窗口 |
| `<C-l>` | normal | 聚焦右窗口 |

#### 代码示例

```lua
-- 按 Esc 清除搜索高亮
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Ctrl+hjkl 进行窗口导航
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
```

---

### 5️⃣ config/lazy.lua - 插件管理器配置

**位置**: `~/.config/nvim/lua/config/lazy.lua`  
**作用**: 配置 lazy.nvim 插件管理器，加载所有插件  
**大小**: 1.8KB

#### 关键配置

```lua
require("lazy").setup({
  spec = {
    -- LazyVim 基础配置
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- 导入所有自定义插件
    { import = "plugins" },
  },
  -- 其他配置...
})
```

#### 插件加载规则

| 配置 | 说明 |
|-----|------|
| `{ import = "plugins" }` | 自动加载 `lua/plugins/*.lua` 中的所有插件 |
| `lazy = false` | 启动时同步加载（不延迟） |
| `auto_install = true` | 缺少的插件自动安装 |

#### 加载的插件文件

lazy.nvim 会自动加载 `lua/plugins/` 目录下的所有 Lua 文件：

```
plugins/
├── ui.lua          → which-key, todo-comments, mini.nvim
├── editor.lua      → telescope, treesitter, gitsigns
├── conform.lua     → conform.nvim
├── lsp.lua         → nvim-lspconfig, mason, fidget
└── terminal.lua    → toggleterm.nvim
```

---

### 6️⃣ plugins/ui.lua - UI 和导航插件

**位置**: `~/.config/nvim/lua/plugins/ui.lua`  
**作用**: 提供用户界面增强和导航工具  
**大小**: 2KB

#### 包含的插件

| 插件 | 功能 | 快捷键 |
|-----|------|-------|
| which-key.nvim | 显示待定快捷键 | `<space>` |
| todo-comments.nvim | 高亮 TODO/FIXME 注释 | 自动 |
| mini.nvim (ai) | 改进的文本对象 | `va)`, `yi'` 等 |
| mini.nvim (surround) | 编辑周围字符 | `sa)`, `sd'`, `sr'` |
| mini.nvim (statusline) | 简单状态栏 | 自动 |

#### which-key 配置

```lua
{
  "folke/which-key.nvim",
  event = "VimEnter",
  opts = {
    delay = 0,
    spec = {
      { "<leader>s", group = "[S]earch" },
      { "<leader>t", group = "[T]oggle" },
      { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
    },
  },
}
```

#### mini.nvim 文本对象示例

```
va)   - 选中括号及其内容
yi'   - 复制引号内内容
ci(   - 改变括号内内容
sd'   - 删除周围引号
sr)'  - 替换周围的)为'
```

---

### 7️⃣ plugins/editor.lua - 编辑器插件

**位置**: `~/.config/nvim/lua/plugins/editor.lua`  
**作用**: 提供核心编辑功能和工具  
**大小**: 3.3KB

#### 包含的插件

| 插件 | 功能 | 快捷键 |
|-----|------|-------|
| telescope.nvim | 模糊查找器 | `<leader>s*` |
| nvim-treesitter | 语法高亮和解析 | 自动 |
| gitsigns.nvim | Git 状态指示 | 自动 |
| guess-indent.nvim | 自动检测缩进 | 自动 |

#### Telescope 快捷键速查

| 快捷键 | 功能 |
|-------|------|
| `<leader>sh` | 搜索帮助文档 |
| `<leader>sk` | 搜索快捷键 |
| `<leader>sf` | 搜索文件 |
| `<leader>sw` | 搜索当前单词 |
| `<leader>sg` | 用 grep 搜索 |
| `<leader>sd` | 搜索诊断信息 |
| `<leader>sr` | 恢复上次搜索 |
| `<leader>s.` | 搜索最近文件 |
| `<leader>/` | 在当前缓冲区模糊搜索 |
| `<leader><leader>` | 查找缓冲区 |

#### Treesitter 支持的语言

```
bash, c, diff, html, lua, markdown, python, vim, ...
```

自动安装，首次启动时下载。

---

### 8️⃣ plugins/conform.lua - 代码格式化

**位置**: `~/.config/nvim/lua/plugins/conform.lua`  
**作用**: 集成代码格式化工具  
**大小**: 756B

#### 包含的工具

| 工具 | 支持的语言 |
|-----|----------|
| stylua | Lua |
| (可扩展) | - |

#### 快捷键

| 快捷键 | 作用 |
|-------|------|
| `<leader>f` | 格式化当前缓冲区 |

#### 自动格式化

- 保存时自动格式化（除 C/C++ 外）
- 超时设置为 500ms

#### 使用示例

```lua
-- 手动格式化
:ConformInfo          " 查看格式化器信息

-- 快捷键格式化
<leader>f             " 格式化当前缓冲区
```

---

### 9️⃣ plugins/lsp.lua - LSP 和语言服务

**位置**: `~/.config/nvim/lua/plugins/lsp.lua`  
**作用**: 配置语言服务器和代码智能  
**大小**: 669B

#### LSP 服务器配置

| 服务器 | 语言 | 安装方式 |
|-------|------|--------|
| pyright | Python | mason |
| gopls | Go | mason |
| lua_ls | Lua | mason |

#### 包含的插件

| 插件 | 功能 |
|-----|------|
| nvim-lspconfig | LSP 配置 |
| mason.nvim | LSP/工具安装器 |
| fidget.nvim | LSP 进度提示 |

#### 常用命令

```vim
:Mason              " 打开 Mason UI 管理 LSP 服务器

" LSP 快捷键（由 LazyVim 提供）
grn                 " 重命名 (go rename)
gra                 " 代码操作 (go action)
grr                 " 查找引用 (go references)
grd                 " 跳转定义 (go definition)
gri                 " 跳转实现 (go implementation)
grt                 " 跳转类型定义 (go type)
gO                  " 文档符号 (open symbols)
gW                  " 工作区符号
<leader>th          " 切换内联提示
```

#### lua_ls 特殊配置

```lua
lua_ls = {
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace",
      },
    },
  },
},
```

---

### 🔟 plugins/terminal.lua - 终端插件

**位置**: `~/.config/nvim/lua/plugins/terminal.lua`  
**作用**: 集成浮动终端  
**大小**: 238B

#### 包含的插件

| 插件 | 功能 | 快捷键 |
|-----|------|-------|
| toggleterm.nvim | 浮动终端 | `<C-\>` |

#### 使用方式

| 快捷键 | 作用 |
|-------|------|
| `<C-\>` | 切换终端 |
| 在终端中 `<Esc><Esc>` | 退出终端模式 |

---

## 插件系统

### 📦 Plugin Spec 格式

每个插件定义是一个 Lua 表，遵循 lazy.nvim 规范：

```lua
{
  "owner/repo",           -- 插件标识 (必需)
  event = "VimEnter",     -- 触发事件
  cmd = { "Command" },    -- 触发命令
  keys = {                -- 触发快捷键
    { "<leader>k", "...", desc = "..." }
  },
  dependencies = { "..." }, -- 依赖的插件
  config = function() ... end, -- 配置函数
  opts = { ... },         -- 自动调用 setup() 的选项
}
```

### 🔄 插件加载策略

| 条件 | 加载时机 |
|-----|--------|
| 无任何条件 | Neovim 启动时 |
| `event = "VimEnter"` | UI 完全加载后 |
| `cmd = { "Telescope" }` | 执行 `:Telescope` 时 |
| `keys = { "<leader>f" }` | 按 `<leader>f` 时 |

### 🎯 依赖关系

```
ui.lua
├── which-key.nvim
├── todo-comments.nvim
│   └─→ plenary.nvim (依赖)
└── mini.nvim

editor.lua
├── telescope.nvim
│   ├─→ plenary.nvim
│   ├─→ telescope-fzf-native.nvim (可选，加速)
│   └─→ telescope-ui-select.nvim
├── nvim-treesitter
├── gitsigns.nvim
└── guess-indent.nvim

conform.lua
└── conform.nvim

lsp.lua
├── nvim-lspconfig
├── mason.nvim
└── fidget.nvim

terminal.lua
└── toggleterm.nvim
```

---

## 快捷键速查

### 🎯 Leader 键绑定 (Leader = `<space>`)

#### 搜索相关 (`<leader>s*`)

```
<leader>sh    Search Help tags
<leader>sk    Search Keymaps
<leader>sf    Search Files
<leader>ss    Search Telescope builtin
<leader>sw    Search current Word
<leader>sg    Search by Grep
<leader>sd    Search Diagnostics
<leader>sr    Search Resume
<leader>s.    Search oldfiles (recent)
<leader>/     Search in current buffer
<leader>s/    Search in open files
<leader><leader>  Find buffers
<leader>sn    Search Neovim config
```

#### 编辑相关

```
<leader>f     Format buffer (conform)
<leader>th    Toggle inlay Hints (LSP)
```

### 🎮 通用快捷键

#### 窗口导航

```
<C-h>         Move to left window
<C-j>         Move to lower window
<C-k>         Move to upper window
<C-l>         Move to right window
```

#### 编辑模式

```
<Esc>         Clear search highlights
<Esc><Esc>    Exit terminal mode
```

#### mini.ai 文本对象

```
va)           Visual select Around )
yi'           Yank Inside '
ci(           Change Inside (
dia           Delete Inside a
```

#### mini.surround 环绕编辑

```
sa)           Surround Add )
sd'           Surround Delete '
sr')          Surround Replace ) to '
sh            Surround Help
```

### 🔌 LSP 快捷键

```
grn           Go Rename
gra           Go Action (code action)
grr           Go References
gri           Go Implementation
grd           Go Definition
grt           Go Type definition
grD           Go Declaration
gO            Open document symbols
gW            Open workspace symbols
<leader>th    Toggle inlay Hints
<leader>q     Open diagnostics list
```

### 📟 终端快捷键

```
<C-\>         Toggle terminal
<Esc><Esc>    Exit terminal mode (在终端内)
```

---

## 常用命令

### 🔍 Neovim 诊断

```vim
:checkhealth            " 检查健康状态
:checkhealth telescope  " 检查 telescope 状态
```

### 📦 插件管理

```vim
:Lazy                   " 打开 Lazy UI (查看插件状态)
:Lazy install           " 安装缺失的插件
:Lazy update            " 更新所有插件
:Lazy clean             " 清理不用的插件
:Lazy sync              " 同步插件 (安装+更新+清理)
```

### 🛠️ 语言服务器

```vim
:Mason                  " 打开 Mason UI (管理 LSP 服务器)
:Mason install pyright  " 安装 Python LSP
:Mason install gopls    " 安装 Go LSP
:MasonToolsInstall      " 安装所有工具
```

### 📝 代码相关

```vim
:ConformInfo            " 查看格式化器信息
:Telescope keymaps      " 搜索快捷键
:Telescope help_tags    " 搜索帮助文档
```

### 🌳 语法树

```vim
:TSUpdate               " 更新 Treesitter 解析器
:TSInstall lua          " 安装特定语言支持
```

---

## 故障排除

### ❓ 插件没有加载

**症状**: 快捷键无效，功能不可用

**解决**:
```vim
:Lazy                   " 检查插件是否安装
:Lazy install           " 安装缺失的插件
:checkhealth            " 诊断问题
```

### ❓ LSP 不工作

**症状**: 没有代码补全、跳转定义不工作

**解决**:
```vim
:checkhealth lsp        " 检查 LSP 状态
:Mason                  " 确认 LSP 服务器已安装
:LspInfo                " 查看当前 LSP 状态
```

### ❓ Treesitter 错误

**症状**: 语法高亮显示不正确

**解决**:
```vim
:TSUpdate               " 更新解析器
:TSInstallInfo          " 查看已安装的语言
:checkhealth treesitter " 诊断 Treesitter
```

### ❓ 快捷键冲突

**症状**: 某些快捷键无效或行为不符

**解决**:
```vim
:Telescope keymaps      " 查看所有已注册的快捷键
:map <C-h>              " 查看特定快捷键的映射
```

---

## 文件修改指南

### 添加新选项

编辑 `lua/config/options.lua`:

```lua
-- 示例：启用相对行号
vim.o.relativenumber = true
```

### 添加新快捷键

编辑 `lua/config/keymaps.lua`:

```lua
-- 示例：映射新快捷键
vim.keymap.set('n', '<leader>xx', function()
  print("Hello!")
end, { desc = 'Say hello' })
```

### 添加新插件

在 `lua/plugins/` 创建新文件或编辑现有文件：

```lua
-- 示例：添加新插件
{
  "plugin/name",
  event = "VimEnter",
  config = function()
    -- 配置代码
  end,
}
```

lazy.nvim 会自动检测并加载该插件。

### 禁用插件

在插件规范中添加 `enabled = false`:

```lua
{
  "plugin/name",
  enabled = false,  -- 禁用此插件
}
```

---

## 性能优化提示

### ⚡ 启动时间检测

```vim
:StartupTime            " 如果有 vim-startuptime 插件
```

### 📊 查看插件加载时间

```vim
:Lazy profile           " 在 Lazy UI 中查看加载时间
```

### 🎯 优化建议

1. **延迟加载非关键插件**: 使用 `event`, `cmd`, `keys` 条件
2. **减少自动启动插件**: 在 `lazy.lua` 中设置 `lazy = true`
3. **清理不用的插件**: `:Lazy clean`
4. **定期更新**: `:Lazy update`

---

## 扩展阅读

- [LazyVim 官方文档](https://www.lazyvim.org)
- [lazy.nvim 文档](https://github.com/folke/lazy.nvim)
- [Kickstart.nvim](https://github.com/nvim-kickstart/kickstart.nvim)
- [Neovim 用户手册](https://neovim.io/doc/user)

---

## 快速参考卡

```
┌─────────────────────────────────────────┐
│         NVIM 配置加载顺序               │
├─────────────────────────────────────────┤
│ 1. init.lua                             │
│    ├─→ config/options.lua               │
│    ├─→ config/autocmds.lua              │
│    ├─→ config/lazy.lua                  │
│    │    └─→ plugins/*.lua               │
│    └─→ config/keymaps.lua               │
│                                         │
│ 文件大小总计: ~10KB                     │
│ 插件数量: 12 个                         │
│ 加载时间: <100ms (通常)                 │
└─────────────────────────────────────────┘
```

---

**最后更新**: 2025-12-14  
**维护者**: Orician  
**许可证**: MIT
