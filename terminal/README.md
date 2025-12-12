## 问题原因
Session "main" already exists but is dead（会话已死亡但未删除）

## 唯一解决方案
```bash
bash ~/Templates/terminal/zellij-manager.sh launch main
```

脚本会自动删除旧会话后启动新会话。

### 推荐：创建别名
```bash
echo "alias zj='bash ~/Templates/terminal/zellij-manager.sh launch main'" >> ~/.bashrc
source ~/.bashrc
zj
```

### KDE Plasma 快捷键
系统设置 → 快捷键和手势 → 新建快捷键
- 命令：`bash ~/Templates/terminal/zellij-manager.sh launch main`
- 快捷键：`Ctrl+Alt+Z`

