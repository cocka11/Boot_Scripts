#/system/bin/sh

dirs=("/system/app" "/system/priv-app" "/system/product/app" "/system/product/priv-app" "/system/system_ext/app" "/system/system_ext/priv-app" "/vendor/app")

mount -o rw,remount /
mount -o rw,remount /vendor

arch_types=($(ls /data/dalvik-cache))

for TYPE_ARCH in "${arch_types[@]}"; do

  for dir in "${dirs[@]}"; do
    
     find "$dir" -name "*.apk" -print0 | while IFS= read -r -d '' apk; do
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
    
              # Heq karakterin e fundit '@' nëse përfundon me '@'
               if [[ "${DEX_DIR: -1}" == "@" ]]; then
                     DEX_DIR="${DEX_DIR%?}"
               fi
     
                    if [ -f "/data/dalvik-cache/$TYPE_ARCH/$DEX_DIR@${APK%.apk}@$APK@classes.dex" ]; then
                    
                         if [ ! -d "$DIR/oat/$TYPE_ARCH" ]; then
                           mkdir -p "$DIR/oat/$TYPE_ARCH" 2>/dev/null
                         fi
                         
                         compiler="speed-profile"
                         variant=`getprop dalvik.vm.isa.$TYPE_ARCH.variant`
                         if dex2oat \
                            --dex-file="$DIR/$APK" \
                            --compiler-filter=$compiler \
                            --instruction-set=$TYPE_ARCH \
                            --instruction-set-variant=$variant \
                            --instruction-set-features=default \
                            --oat-file="$DIR/oat/$TYPE_ARCH/${APK%.apk}.odex"; then
                            echo  "Sukses: $APK u kompilua në odex."
                            chmod -R a=r,a+X,u+w "$DIR"
                         else
                            echo  "Gabim në kompilimin e $APK në odex."
                        fi
                            rm -f /data/dalvik-cache/$TYPE_ARCH/$DEX_DIR@${APK%.apk}@$APK@classes.*
                   fi
              done
          done
    done
done
