#!/bin/sh
#
# Taken from http://www.raspberryvi.org/wiki/doku.php/raspi-expand-rootfs
#
# Modded version of expand-rootfs in raspi-config for Kali 2018.2-nexmon-re4son_kernel
#

# Get the starting offset of the root partition
PART_START=$(parted /dev/mmcblk0 -ms unit s p | grep "^2" | cut -f 2 -d: | sed 's/.$//')
[ "$PART_START" ] || return 1
# Return value will likely be error for fdisk as it fails to reload the
# partition table because the root fs is mounted
fdisk /dev/mmcblk0 <<EOF
p
d
2
n
p
2
$PART_START

n
p
w
EOF

# now set up an init.d script
cat <<\EOF > /etc/init.d/resize2fs_once &&
#!/bin/sh
### BEGIN INIT INFO
# Provides:          resize2fs_once
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5 S
# Default-Stop:
# Short-Description: Resize the root filesystem to fill partition
# Description:
### END INIT INFO
. /lib/lsb/init-functions
case "$1" in
  start)
    log_daemon_msg "Starting resize2fs_once" &&
    resize2fs /dev/mmcblk0p2 &&
    rm /etc/init.d/resize2fs_once &&
    update-rc.d resize2fs_once remove &&
    log_end_msg $?
    ;;
  *)
    echo "Usage: $0 start" >&2
    exit 3
    ;;
esac
EOF
chmod +x /etc/init.d/resize2fs_once &&
update-rc.d resize2fs_once defaults &&
read -p "Bolum genisletildi. Sistemi yeniden baslatmak icin bir tusa basin..." &&
reboot
