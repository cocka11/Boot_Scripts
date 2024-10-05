#!/system/bin/sh

# Përshkrim: Ky skript ndryshon lejet e skedarëve boot_script.sh dhe boot_scripts.rc
# Përdorimi: Vendoseni këtë skript në direktorinë e modulit tuaj Magisk

# Definoni rrugën e modulit tuaj Magisk
MODULE_PATH="/data/adb/modules/boot_scripts"
chmod 755 "$MODULE_PATH/system/xbin/boot_script.sh"
