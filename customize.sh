#!/system/bin/sh

mount -o rw,remount /

set_perm /system/etc/init/boot_script.rc 0 0 0644
if [ ! -d /system/xbin ]; them
   mkdir /system/xbin
   set_perm /system/etc/init/boot_script.sh 0 0 0755
fi
