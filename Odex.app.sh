#!/system/bin/sh

cleanup_odex() {
    local dir="$1"
    mount -o rw,remount /
    mount -o rw,remount /vendor
    if [ -d "$dir" ]; then
        find "$dir" -type d -name "oat" -mtime +1 -exec rm -rf {} \;
    fi
}

dirs=("/system/app" "/system/priv-app" "/system/product/app" "/system/product/priv-app" "/system/system_ext/app" "/system/system_ext/priv-app" "/vendor/app")

change_permissions() {
  local dir="$1"
  if [ -d "$dir" ]; then
    find "$dir" -type f -exec chmod 644 {} +
    find "$dir" -type d -exec chmod 755 {} +
  fi
}

for dir in "${dirs[@]}"; do
    cleanup_odex $dir
    find "$dir" -name "*.apk" -print0 | while IFS= read -r -d ''  apk; do
    DIR=$(dirname "$apk")
    APK=$(basename "$apk")
    
new_dirs=()

         for EDIT_DIR in "${dirs[@]}"; do
             new_dir="${EDIT_DIR//\//@}"
             new_dir="${new_dir/\/system/}"
             new_dirs+=("$new_dir")
         done

             for EDIT_DIR_NAME in "${new_dirs[@]}"; do
                 DEX_DIR=${EDIT_DIR_NAME/#@/}
    
                 for TYPE_ARCH in $(ls /data/dalvik-cache); do
     
                    if [ ! -d "$DIR/oat/$TYPE_ARCH" ] && [ -f "/data/dalvik-cache/$TYPE_ARCH/$DEX_DIR@${APK%.apk}@$APK@classes.dex" ]; then
                      oat_dir="$DIR/oat/$TYPE_ARCH"
                      apk_file="$DIR/$APK"      
                      oat_file="$oat_dir/${APK%.apk}.odex"
                      mkdir -p "$oat_dir" 2>/dev/null
                      compiler="speed-profile"
                      variant=`getprop dalvik.vm.isa.$TYPE_ARCH.variant`
                      echo "Compiling $APK to odex..."
                      dex2oat \
                      --dex-file="$apk_file" \
                      --compiler-filter=$compiler \
                      --instruction-set=$TYPE_ARCH \
                      --instruction-set-variant=$variant \
                      --instruction-set-features=default \
                      --oat-file="$oat_file"
                      change_permissions "$DIR"
                      rm -rf /data/dalvik-cache/$TYPE_ARCH/$DEX_DIR@${APK%.apk}@$APK@classes.*
                   fi
                done
            done
        done
done
