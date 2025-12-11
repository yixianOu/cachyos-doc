#!/usr/bin/env fish
# Simplified USB init + backup script
# Date: 2025-11-09T14:48:41.138Z
# WARNING: Destroys ALL data on /dev/sda

set -l DEV /dev/sda
set -l PART /dev/sda1
set -l LABEL USB_EXT4

printf "Device: %s\n" $DEV
lsblk -rpno NAME,RM,TYPE,SIZE,MOUNTPOINT,FSTYPE $DEV
printf "Type YES to format %s as ext4 and continue: " $DEV; read -l CONFIRM
if test "$CONFIRM" != "YES"
  echo "Abort."; exit 1
end

# Create single ext4 partition
sudo parted $DEV --script mklabel gpt mkpart primary ext4 1MiB 100%
sudo partprobe $DEV
for i in (seq 1 10)
  test -b $PART; and break; sleep 1
end
if not test -b $PART
  echo "Partition $PART not found."; exit 2
end

# Format ext4
sudo mkfs.ext4 -F -L $LABEL $PART

# Mount
udisksctl mount -b $PART >/dev/null 2>&1
set -l MNT (lsblk -nrpo MOUNTPOINT $PART | head -n1)
if test -z "$MNT"
  set -l USER (id -un)
  set -l MNT /run/media/$USER/$LABEL
  sudo mkdir -p $MNT
  sudo mount $PART $MNT
end

echo "Mounted at: $MNT"

# Collect sources
set -l USER (id -un)
set -l SRC
for p in $HOME/.config/alacritty $HOME/.config/tmux $HOME/.tmux.conf $HOME/.config/fish
  test -e $p; and set SRC $SRC $p
end
if test (count $SRC) -eq 0
  echo "No config paths found."; exit 0
end

# Ensure /home path root
mkdir -p $MNT/home/$USER

# Backup preserving relative paths
rsync -aR --relative $SRC $MNT/

echo "Backup complete. Listing copied roots:" 
for p in $SRC
  set rel (string replace -r '^/' '' $p)
  echo "$MNT/$rel"
end

echo "To unmount: udisksctl unmount -b $PART  (or) sudo umount $MNT"
