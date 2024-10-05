#!/system/bin/sh

# Përshkrim: Ky skript ndryshon lejet e skedarëve boot_script.sh dhe boot_scripts.rc
# Përdorimi: Vendoseni këtë skript në direktorinë e modulit tuaj Magisk

# Definoni rrugën e modulit tuaj Magisk
MODULE_PATH="/data/adb/modules/boot_scripts"

# Kontrolloni nëse direktoria ekziston
if [ -d "$MODULE_PATH" ]; then
    # Ndryshoni lejet për boot_script.sh në 755
    if [ -f "$MODULE_PATH/boot_script.sh" ]; then
        chmod 755 "$MODULE_PATH/boot_script.sh"
        echo "Lejet e boot_script.sh janë ndryshuar në 755"
    else
        echo "boot_script.sh nuk u gjet në $MODULE_PATH"
    fi

    # Ndryshoni lejet për boot_scripts.rc në 644
    if [ -f "$MODULE_PATH/boot_scripts.rc" ]; then
        chmod 644 "$MODULE_PATH/boot_scripts.rc"
        echo "Lejet e boot_scripts.rc janë ndryshuar në 644"
    else
        echo "boot_scripts.rc nuk u gjet në $MODULE_PATH"
    fi
else
    echo "Direktoria e modulit nuk u gjet: $MODULE_PATH"
fi
