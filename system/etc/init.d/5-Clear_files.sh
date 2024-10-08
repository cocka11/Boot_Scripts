#!/system/bin/sh

# Definon një array me direktoritë që dëshiron të kontrollosh
DIRS=("/data/tombstones" "/data/system/dropbox" "/data/backup/pending" "/data/anr" "/cache/recovery" "/cache")

# Iteron nëpër çdo direktori të dhënë
for DIR in "${DIRS[@]}"; do
    DIR_NAME=$(basename "$DIR")
    echo " KONTROLLI Kontrollimi i direktorisë: {$DIR_NAME}"
    if [ -d "$DIR" ]; then
        found_files=false
        # Variabël lokale për të numëruar skedarët e fshirë në këtë direktori
        local_deleted_files=0

        for FILE in "$DIR"/*; do
                rm -rf "$FILE"
                found_files=true
                if [ $? -eq 0 ]; then
                    ((local_deleted_files++)) # Rritet numri i skedarëve të fshirë lokalë
               fi
        done

        if [ "$found_files" = true ]; then
            echo "TOTALI Direktoria '{$DIR_NAME}' u pastrua. Numri total i skedarëve të fshirë: [$local_deleted_files]"
        else
            echo "KËRKIM Nuk u gjetën skedarë për të fshirë në direktorinë '{$DIR_NAME}'. Direktoria është tashmë e pastër."
        fi
    else
        echo "VERIFIKIM Direktoria '{$DIR_NAME}' nuk ekziston."
    fi
done
