#!/system/bin/sh

# mounted data
mount -o rw,remount /data

SEARCH_DIRS=("/data/media/0/Android/data/" "/data/data" "/data/user/0" "/data/user_de/0" "/sdcard/Android/data")

TARGET_NAMES=("cache" "code_cache")

for dir in "${SEARCH_DIRS[@]}"; do
    for target in "${TARGET_NAMES[@]}"; do
        find "$dir" -type d -name "$target" -mindepth 2 | while read found_dir; do
            size_before=$(du -sh "$found_dir" | cut -f1)
            rm -rf "$found_dir" && echo "$(date +"%H:%M:%S %d-%m-%Y") Fshirë: $found_dir, - Madhësia e fshirë: $size_before"
       done
   done
done

rm -rf /storage/ABA8-09F8/LOST.DIR 2>/dev/null
rm -rf /storage/ABA8-09F8/Movies 2>/dev/null
rm -rf /storage/ABA8-09F8/Music 2>/dev/null
rm -rf /storage/ABA8-09F8/Pictures 2>/dev/null
rm -rf /data/magisk* 2>/dev/null
