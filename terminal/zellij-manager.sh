#!/usr/bin/env bash
# Zellij 启动脚本 - 解决 Alacritty 集成启动闪退
# 原因: "Session already exists but is dead" 错误（运行时目录残留）
# 解决: 清理 /run/user/$UID/zellij 和 ~/.cache/zellij 后启动

launch() {
    local name="${1:-main}"
    
    # 清理运行时数据（关键！）
    rm -rf /run/user/$UID/zellij/* 2>/dev/null || true
    rm -rf ~/.cache/zellij/* 2>/dev/null || true
    
    # 启动新会话
    exec zellij -s "$name"
}

list_sessions() {
    zellij list-sessions 2>/dev/null
}

cmd="${1:-help}"
case "$cmd" in
    launch) launch "$2" ;;
    list) list_sessions ;;
    clean-all) 
        pkill -9 zellij 2>/dev/null || true
        rm -rf /run/user/$UID/zellij/* 2>/dev/null || true
        rm -rf ~/.cache/zellij/* 2>/dev/null || true
        echo "✓ Zellij已完全清理"
        ;;
    *)
        echo "Zellij 启动管理工具"
        echo "用法: $0 [launch|list|clean-all] [会话名]"
        ;;
esac
