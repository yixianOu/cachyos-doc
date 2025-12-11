# Zellij 快速参考

## 配置
- **主题**：Catppuccin Mocha
- **默认 Shell**：Fish
- **配置文件**：`~/.config/zellij/config.kdl`

---

## 快捷键

### Tab 管理
| 快捷键 | 功能 |
|-------|------|
| **Ctrl+T** | 新建 Tab |
| **Ctrl+W** | 关闭 Tab |
| **Ctrl+P** | 前一个 Tab |
| **Ctrl+N** | 下一个 Tab |

### Pane 管理
| 快捷键 | 功能 |
|-------|------|
| **Alt+D** | 下方分割 |
| **Alt+R** | 右侧分割 |
| **Alt+X** | 关闭当前 Pane |

### 焦点移动
| 快捷键 | 功能 |
|-------|------|
| **Alt+↑** | 上 |
| **Alt+↓** | 下 |
| **Alt+←** | 左 |
| **Alt+→** | 右 |

### 调整窗格
| 快捷键 | 功能 |
|-------|------|
| **Ctrl+Alt+H** | 左 |
| **Ctrl+Alt+J** | 下 |
| **Ctrl+Alt+K** | 上 |
| **Ctrl+Alt+L** | 右 |

### 其他
| 快捷键 | 功能 |
|-------|------|
| **Ctrl+F** | 全屏切换 |
| **Ctrl+Alt+F** | 浮窗切换 |
| **Ctrl+D** | 分离会话 |
| **Ctrl+G** | 锁定模式 |
| **Alt+S** | 滚动模式 |

### 滚动模式
| 快捷键 | 功能 |
|-------|------|
| **J** | 下 |
| **K** | 上 |
| **E** | 编辑 |
| **Esc** | 退出 |

---

## 提示

- **锁定模式**：按 `Ctrl+G` 禁用快捷键（需要在终端输入 Zellij 快捷键时）
- **浮窗**：`Ctrl+Alt+F` 切换浮窗模式
- **分离会话**：`Ctrl+D` 后用 `zellij attach <name>` 重新连接

---

## 会话管理

```bash
zellij              # 新会话
zellij -s name      # 命名会话
zellij list-sessions
zellij attach <name>
```

---

## 主题推荐

### Catppuccin Mocha ⭐
当前使用的主题，现代深色配色，适合长时间编码。

特点：
- 柔和的配色方案
- 良好的代码高亮效果
- 支持透明度

其他可用主题：
```bash
zellij list-themes
```

参考：[witjem/zellij-themes](https://github.com/witjem/zellij-themes)

---

## 快捷键配置建议

### Tmux 风格（参考）

如需使用 Tmux 风格快捷键（Ctrl+B 前缀），可参考以下配置：

```kdl
keybinds clear-defaults=true {
    normal {
        // Tab 管理
        bind "Ctrl b c" { NewTab; SwitchToMode "normal"; }
        bind "Ctrl b x" { CloseTab; SwitchToMode "normal"; }
        bind "Ctrl b p" { GoToPreviousTab; SwitchToMode "normal"; }
        bind "Ctrl b n" { GoToNextTab; SwitchToMode "normal"; }
        
        // Pane 管理
        bind "Ctrl b \"" { NewPane "down"; SwitchToMode "normal"; }
        bind "Ctrl b %" { NewPane "right"; SwitchToMode "normal"; }
        bind "Ctrl b Up" { MoveFocus "up"; }
        bind "Ctrl b Down" { MoveFocus "down"; }
        bind "Ctrl b Left" { MoveFocus "left"; }
        bind "Ctrl b Right" { MoveFocus "right"; }
        
        // 调整窗格大小
        bind "Ctrl b h" { Resize "Increase left"; }
        bind "Ctrl b j" { Resize "Increase down"; }
        bind "Ctrl b k" { Resize "Increase up"; }
        bind "Ctrl b l" { Resize "Increase right"; }
    }
}
```

---

## 常见问题

**Q: 如何快速切换主题？**  
A: 编辑 `~/.config/zellij/config.kdl` 中的 `theme "xxx"` 行，保存后重启 Zellij。

**Q: 如何在多个快捷键方案之间切换？**  
A: 将不同方案保存为单独的配置文件，启动时指定：
```bash
zellij -c ~/.config/zellij/custom-keybinds.kdl
```

**Q: 主题支持透明度吗？**  
A: 部分主题支持。需要终端模拟器（如 Alacritty）也支持透明度。
