方法1（推荐）：

     paru -S $(cat wsl_arch_terminal_packages.txt | tr '\n' ' ')

   方法2： 使用 xargs

     cat wsl_arch_terminal_packages.txt | xargs paru -S

   方法3： 循环安装（如果某个包安装失败不会中断）

     while read pkg; do paru -S "$pkg"; done < wsl_arch_terminal_packages.txt

## Step 2: 迁移CLI工具配置文件

在WSL中执行以下scp命令迁移配置文件：

### Fish配置
```bash
scp -r cachy:~/.config/fish ~/.config/
```

### Zellij配置
```bash
scp -r cachy:~/.config/zellij ~/.config/
```

### Neovim配置
```bash
scp -r cachy:~/.config/nvim ~/.config/
```

### Vim配置
```bash
scp -r cachy:~/.vim ~/
scp cachy:~/.vimrc ~/
```

### Git配置
```bash
scp cachy:~/.gitconfig ~/
scp -r cachy:~/.config/git ~/.config/
```

### SSH配置
```bash
scp -r cachy:~/.ssh ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub ~/.ssh/config ~/.ssh/authorized_keys 2>/dev/null
```

### Bat配置
```bash
scp -r cachy:~/.config/bat ~/.config/
```

### FZF配置
```bash
scp cachy:~/.fzf.bash ~/
scp cachy:~/.fzf.zsh ~/
```

### 批量迁移常用配置
```bash
# 创建必要目录
mkdir -p ~/.config

# 迁移所有配置
scp -r cachy:~/.config/fish ~/.config/
scp -r cachy:~/.config/zellij ~/.config/
scp -r cachy:~/.config/nvim ~/.config/
scp -r cachy:~/.config/bat ~/.config/
scp -r cachy:~/.config/git ~/.config/
scp cachy:~/.gitconfig ~/
scp cachy:~/.vimrc ~/
scp -r cachy:~/.vim ~/
```

### 注意事项
- 确保WSL中已配置好SSH登录（密钥或密码）
- SSH config中的 `cachy` 别名需要提前配置
- 某些敏感文件（如SSH私钥）传输后需要修改权限
- 可根据需要选择性迁移特定工具的配置
