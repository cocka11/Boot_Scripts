#!/system/bin/sh

MODDIR=${0%/*}
chown 0:0 $MODDIR/common/post-fs-data.sh.sh;
chmod 775 $MODDIR/common/post-fs-data.sh.sh;
