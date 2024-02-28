#/system/system_ext/bin/bash

dirs=("/system/app" "/system/priv-app" "/system/product/app" "/system/product/priv-app" "/system/system_ext/app" "/system/system_ext/priv-app" "/vendor/app")

     mount -o rw,remount /
     mount -o rw,remount /vendor

for dir in "${dirs[@]}"; do
    
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
    
              # Heq karakterin e fundit '@' nëse përfundon me '@'
               if [[ "${DEX_DIR: -1}" == "@" ]]; then
                     DEX_DIR="${DEX_DIR%?}"
               fi
    
                   for TYPE_ARCH in $(ls /data/dalvik-cache); do
     
                       if [ -f "/data/dalvik-cache/$TYPE_ARCH/$DEX_DIR@${APK%.apk}@$APK@classes.dex" ]; then
                       
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
                         chmod -R a=r,a+X,u+w $oat_dir
                         rm -f /data/dalvik-cache/$TYPE_ARCH/$DEX_DIR@${APK%.apk}@$APK@classes.*
                      fi
                  done
          done
     done
done

for DIR_BASE in $(ls /apex); do
    for NAME in /apex/$DIR_BASE/priv-app /apex/$DIR_BASE/app /apex/$DIR_BASE/javalib; do
        for ALL_DIR in "$NAME"/* ; do
            DIR_APP=$(dirname "$ALL_DIR")
            DIR_NAME=$(basename "$ALL_DIR")
            DIR2=$(basename $NAME)
            CUT=${DIR_NAME%%@*}
            compiler="speed-profile"
            mount -o rw,remount /apex/$DIR_BASE 2>/dev/null
            for ARCH in $(ls /data/dalvik-cache); do
                variant=`getprop dalvik.vm.isa.$ARCH.variant`
                if [[ $NAME == "/apex/$DIR_BASE/priv-app" || $NAME == "/apex/$DIR_BASE/app" ]]; then
                    if [ -f $DIR_APP/$DIR_NAME/$CUT.apk ]; then
                        if [ -f "/data/dalvik-cache/$ARCH/apex@$DIR_BASE@$DIR2@$DIR_NAME@$CUT.apk@classes.dex" ]; then
                           mkdir -p $DIR_APP/$DIR_NAME/oat/$ARCH                         
                           dex2oat \
                           --dex-file="$DIR_APP/$DIR_NAME/$CUT.apk" \
                           --compiler-filter=$compiler \
                           --instruction-set=$ARCH \
                           --instruction-set-variant=$variant \
                           --instruction-set-features=default \
                           --oat-file="$DIR_APP/$DIR_NAME/oat/$ARCH/$CUT.odex"
                           echo "Compiling $CUT.apk to odex..."
                           chmod -R a=r,a+X,u+w $DIR_APP
                           rm -rf /data/dalvik-cache/$ARCH/apex@$DIR_BASE@$DIR2@$DIR_NAME@$CUT.apk@classes.*
                       fi
                    fi          
                elif [[ $NAME == "/apex/$DIR_BASE/javalib" ]]; then
                      if [ -f $NAME/$DIR_NAME ]; then
                          if [ -f "/data/dalvik-cache/$ARCH/apex@$DIR_BASE@$DIR2@$DIR_NAME@classes.dex" ]; then
                            mkdir -p $DIR_APP/oat/$ARCH
                            dex2oat \
                            --dex-file="$DIR_APP/$DIR_NAME" \
                            --compiler-filter=$compiler \
                            --instruction-set=$ARCH \
                            --instruction-set-variant=$variant \
                            --instruction-set-features=default \
                            --oat-file="$DIR_APP/oat/$ARCH/${DIR_NAME%.jar}.odex"
                            echo "Compiling $DIR_NAME to odex..."
                            chmod -R a=r,a+X,u+w $DIR_APP
                            rm -rf /data/dalvik-cache/$ARCH/apex@$DIR_BASE@$DIR2@$DIR_NAME@classes.*
                         fi
                     fi
                fi                 
           done
       done
   done
done
