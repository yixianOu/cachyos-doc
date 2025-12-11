# Tmux 历史配置 - 已迁移至 Zellij

**状态**：✅ 已完全迁移到 Zellij  
**详细配置**：见 `ZELLIJ_QUICK_REFERENCE.md`

---

## 迁移说明

### Tmux 快捷键快速参考

Tmux 采用 **Ctrl+B 前缀** 来执行命令：

| 操作 | 快捷键 |
|-----|--------|
| 新建窗口 | `Ctrl+B, C` |
| 关闭窗口 | `Ctrl+B, X` |
| 前一个窗口 | `Ctrl+B, P` |
| 下一个窗口 | `Ctrl+B, N` |
| 水平分割（上下） | `Ctrl+B, "` |
| 竖直分割（左右） | `Ctrl+B, %` |
| 焦点移动 | `Ctrl+B, 方向键` |
| 调整大小 | `Ctrl+B, H/J/K/L` |
| 分离会话 | `Ctrl+B, D` |

### 迁移到 Zellij

**好消息**：Zellij 采用 **相同的 Tmux 快捷键风格**，无需重新学习！

见 `ZELLIJ_QUICK_REFERENCE.md` 中的完整对比表和详细配置。

---

## 启动命令

```bash
# 原来 (Tmux)
alacritty -e tmux new-session -A -s main

# 现在 (Zellij) ✅
alacritty -e zellij -s main
zellij                    # 快速启动
zellij -s myproject       # 命名会话
```

---

## 配置文件位置

| 工具 | 配置文件 | 状态 |
|-----|--------|------|
| Tmux | `~/.tmux.conf` | 存档 |
| Zellij | `~/.config/zellij/config.kdl` | ✅ 活跃 |
| Alacritty | `~/.config/alacritty/alacritty.toml` | ✅ 保留 |

