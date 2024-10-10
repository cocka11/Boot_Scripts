#!/system/bin/sh

echo -n boot_script.sh > /sys/power/wake_lock

source /system/bin/disable_power_save.sh

# Vendosni një flag për të kontrolluar ekzekutimin e skriptit
executed=false
start_time=0

# Funksion për të llogaritur diferencën e kohës në sekonda
time_diff_in_seconds() {
    echo $(($(date +%s) - $1))
}

# Funksion për të loguar mesazhe
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_DIR/script_execution.log"
}

# Cikli kryesor për kontrollin e statusit të ekranit dhe ekzekutimin e kodit kur ekrani fiket
while true; do
    # Kontrollo statusin e ekranit duke përdorur vetëm awk
    status=$(dumpsys display | awk -F'=' '/mScreenState/ {gsub(/ /, "", $2); print $2}')
    
    if [ "$status" = "OFF" ]; then
        if [ "$executed" = false ]; then
            # Nëse ekrani sapo është fikur, regjistro kohën e fillimit
            if [ "$start_time" -eq 0 ]; then
                start_time=$(date +%s)
            fi
            
            # Llogarit diferencën e kohës që nga fikja e ekranit
            elapsed_time=$(time_diff_in_seconds $start_time)
            
            if [ "$elapsed_time" -ge 300 ]; then
                sh /system/bin/enable_power_save.sh
                # Montimi i sistemit si të shkruajtshëm
                mount -o rw,remount /

                # Defino direktorine për skedarët e log-ut
                LOG_DIR="/data/Arbri"

                # Krijo direktorine për log-et vetëm nëse ajo nuk ekziston
                if [ ! -d "$LOG_DIR" ]; then
                    mkdir -p "$LOG_DIR"
                fi

                # Kontrollo dhe krijo direktorine /system/etc/init.d nëse nuk ekziston
                if [ ! -d "/system/etc/init.d" ]; then
                    mkdir -p "/system/etc/init.d"
                fi

                # Vendos lejet 755 për të gjitha skriptet në /system/etc/init.d
                chmod 755 /system/etc/init.d/*

                # Ekzekuto çdo skript që ndodhet në direktorine /system/etc/init.d
                for script in /system/etc/init.d/*; do
                    # Kontrollo nëse skedari është ekzekutueshëm
                    if [ -x "$script" ]; then
                        # Përcakto emrin e skedarit të log-ut bazuar vetëm në emrin e skriptit
                        script_name=$(basename "$script")
                        log_file="$LOG_DIR/${script_name}.log"
                        
                        # Ekzekuto skriptin dhe ruaj output-in në skedarin përkatës të log-ut
                        "$script" > "$log_file" 2>&1
                    fi
                done

                # Ekzekuto kodin vetëm nëse ekrani është fikur dhe skripti nuk është ekzekutuar më parë
                log_message "Ekrani fiket, ekzekutimi i skriptit."
                
                # Vendos flag-un për të treguar se ekzekutimi ka ndodhur
                executed=true
            fi
        fi
    else
        # Rivendos flag-un dhe kohën e fillimit në 0 kur ekrani ndizet
        executed=false
        start_time=0
        disable_power_save
        # Fli për një kohë më të gjatë para se të kontrollohet përsëri
        sleep 60
    fi

    # Prit për disa sekonda para se të kontrollohet përsëri
    sleep 5
done
