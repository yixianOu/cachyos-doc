#!/bin/bash
#
# KDE Plasma 6 应用启动问题一键修复脚本
# Fixes: "Unit app-org.kde.dolphin@... service not found"
#

set -e

echo "=== KDE Plasma 应用启动问题修复 ==="
echo ""

# Step 1: 禁用KDE应用作为systemd scope
echo "[1/3] 配置KDE应用启动方式..."
mkdir -p ~/.config/plasma-workspace/env
cat > ~/.config/plasma-workspace/env/disable_app_scope.sh << 'EOF'
#!/bin/bash
# Disable KDE applications as scope to avoid systemd service launcher issues
export KDE_APPLICATIONS_AS_SCOPE=0
EOF
chmod +x ~/.config/plasma-workspace/env/disable_app_scope.sh
echo "✓ 已禁用KDE_APPLICATIONS_AS_SCOPE"

# Step 2: 清理会话文件
echo "[2/3] 清理会话状态..."
rm -rf ~/.config/session/* 2>/dev/null || true
echo "✓ 已清理会话文件"

# Step 3: 清理stale transient services
echo "[3/3] 清理系统服务..."
rm -f /run/user/1000/systemd/transient/app-*.service 2>/dev/null || true
systemctl --user daemon-reload
echo "✓ 已清理transient services"

echo ""
echo "=== 修复完成 ==="
echo ""
echo "请重启KDE Plasma以应用变更:"
echo "  systemctl --user restart plasma"
echo "或重启系统:"
echo "  reboot"
echo ""
echo "验证修复:"
echo "  systemctl --user list-unit-files | grep app-"
echo "  echo \$KDE_APPLICATIONS_AS_SCOPE"
