#!/system/bin/sh

MODDIR=${0%/*}
chown 0:0 $MODDIR/system/bin/boot_script.sh;
chmod 775 $MODDIR/system/bin/boot_script.sh;
