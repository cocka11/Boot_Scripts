#!/system/bin/sh

MODDIR=${0%/*}
SCRIPT="$MODDIR/system/bin/boot_script.sh"
SCRIPT_init="$MODDIR/system/etc/init.d/*
chown 0:0 "$SCRIPT_init"
chmod 775 "$SCRIPT_init"
# Check if the script exists
if [ -f "$SCRIPT" ]; then
    # Change ownership and check for errors
    chown 0:0 "$SCRIPT"
    # Change permissions and check for errors
    chmod 775 "$SCRIPT"
    sh "$SCRIPT"
fi
