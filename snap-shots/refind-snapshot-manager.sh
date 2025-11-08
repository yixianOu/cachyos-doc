#!/bin/bash
# rEFInd Snapshot Boot Manager for CachyOS with btrfs
# 自动扫描 /.snapshots/* 并生成 rEFInd 启动菜单项
# 使用方式: sudo ./refind-snapshot-manager.sh [--validate-only|--restore]

set -euo pipefail

SNAPSHOTS_DIR="/.snapshots"
REFIND_LINUX_CONF="/boot/refind_linux.conf"
REFIND_LINUX_BAK="${REFIND_LINUX_CONF}.bak"

get_root_uuid() {
    btrfs filesystem show / 2>/dev/null | grep "UUID:" | head -1 | awk '{print $NF}'
}

validate_config() {
    local conf_file="$1"
    [ ! -f "$conf_file" ] && { echo "[!] Config file not found: $conf_file"; return 1; }
    
    local root_uuid=$(get_root_uuid)
    grep -q "root=UUID=$root_uuid" "$conf_file" || { echo "[!] Invalid UUID in config"; return 1; }
    
    local snapshot_count=$(grep -c "^\"Snapshot:" "$conf_file" || true)
    echo "[✓] Config valid: $snapshot_count snapshot entries"
    return 0
}

restore_backup() {
    if [ -f "$REFIND_LINUX_BAK" ]; then
        cp "$REFIND_LINUX_BAK" "$REFIND_LINUX_CONF"
        echo "[+] Restored from backup"
        return 0
    else
        echo "[!] No backup file found"
        return 1
    fi
}

generate_refind_linux_conf() {
    local root_uuid=$(get_root_uuid)
    
    {
        echo '# CachyOS Snapshot Boot Options'
        echo '"Boot with standard options"    "quiet splash rw rootflags=subvol=/@ root=UUID='"$root_uuid"'"'
        echo '"Boot to single-user mode"      "quiet splash rw rootflags=subvol=/@ root=UUID='"$root_uuid"'" single'
        echo ''
        echo '# Snapshots'
        
        if [ -d "$SNAPSHOTS_DIR" ]; then
            find "$SNAPSHOTS_DIR" -maxdepth 1 -type d ! -name snapshots | sort -r | while read -r snapshot; do
                local snapshot_name=$(basename "$snapshot")
                local subvol_path="@snapshots/$snapshot_name/snapshot"
                echo "\"Snapshot: $snapshot_name\"    \"quiet splash rw rootflags=subvol=$subvol_path root=UUID=$root_uuid\""
            done
        fi
    }
}

main() {
    local cmd="${1:-}"
    
    case "$cmd" in
        --validate-only)
            validate_config "$REFIND_LINUX_CONF"
            exit $?
            ;;
        --restore)
            restore_backup
            exit $?
            ;;
        "")
            ;;
        *)
            echo "[!] Unknown option: $cmd"
            exit 1
            ;;
    esac
    
    echo "[*] CachyOS rEFInd Snapshot Boot Manager"
    
    if [ ! -d "$SNAPSHOTS_DIR" ]; then
        echo "[!] Snapshots directory not found: $SNAPSHOTS_DIR"
        exit 1
    fi
    
    local count=$(find "$SNAPSHOTS_DIR" -maxdepth 1 -type d ! -name snapshots | wc -l)
    echo "[+] Found $count snapshots"
    
    if [ ! -w "$REFIND_LINUX_CONF" ]; then
        echo "[!] No write permission to $REFIND_LINUX_CONF"
        echo "[*] Run with sudo: sudo $0"
        exit 1
    fi
    
    local config=$(generate_refind_linux_conf)
    cp "$REFIND_LINUX_CONF" "$REFIND_LINUX_BAK"
    echo "[+] Backed up to $REFIND_LINUX_BAK"
    
    echo "$config" > "$REFIND_LINUX_CONF"
    echo "[+] Updated $REFIND_LINUX_CONF"
    
    if validate_config "$REFIND_LINUX_CONF"; then
        echo "[✓] Done! Reboot to see snapshot options in rEFInd boot menu"
    else
        restore_backup
        echo "[!] Config validation failed, restored backup"
        exit 1
    fi
}

main "$@"
