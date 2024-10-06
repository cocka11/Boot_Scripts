#!/system/bin/sh

MODDIR=${0%/*}
chown 0:0 $MODDIR/common/boot_script.sh;
chmod 775 $MODDIR/common/boot_script.sh;
