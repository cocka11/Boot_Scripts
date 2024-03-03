#!/system/bin/sh

echo -n boot_script.sh > /sys/power/wake_lock

# Pjesa e konfigurueshme
log_dir="/data/Arbri"
execution_interval_minutes=180
max_attempts=1

# Kontrolloni dhe krijoni folderin e log nëse nuk ekziston
if [ ! -d "$log_dir" ]; then
  mkdir -p "$log_dir"
  chmod 755 "$log_dir"
fi

success_log_file="$log_dir/success_file.log"
error_log_file="$log_dir/error_file.log"
execution_time_log_file="$log_dir/execution_time_file.log"
stop="$log_dir/stop"
execution_flag="$log_dir/execution_flag"

# Krijoni skedarët log nëse nuk ekzistojnë
[ -f "$success_log_file" ] || touch "$success_file.log"
[ -f "$error_log_file" ] || touch "$error_file.log"
[ -f "$execution_time_log_file" ] || touch "$execution_time_file.log"

# mounted system
mount -o rw,remount /

# Pastroi flag-in e ekzekutimit në fillim
echo "0" > "$execution_flag"

# Kontrolloni dhe krijoni folderin e skripteve nëse nuk ekziston
initd_dir="/system/etc/init.d"
if [ ! -d "$initd_dir" ]; then
  mkdir -p "$initd_dir"
  chmod 755 "$initd_dir"
fi

# Ndryshoni lejet e skriptave në direktorinë init.d
for script_perm in "$initd_dir"/*; do
    if [ -f "$script_perm" ]; then
       chmod 755 "$script_perm"
    fi
done

while true; do
    current_hour=$(date +"%H")
    current_minute=$(date +"%M")
    total_minutes_since_midnight=$((current_hour * 60 + current_minute))

    minutes_until_next_execution=$((execution_interval_minutes - total_minutes_since_midnight % execution_interval_minutes))
    seconds_until_next_execution=$((minutes_until_next_execution * 60))
    
    Next_exe=$(date +"%H:%M:%S %d-%m-%Y")
    echo "$Next_exe: Sleeping for $seconds_until_next_execution seconds until the next execution." >> "$execution_time_log_file"
    echo "=====================================" >> "$execution_time_log_file"
    sleep $seconds_until_next_execution
    
    # Kontrolloni nëse një ekzekutim është ende aktiv
    if [ "$(cat "$execution_flag")" -eq "1" ]; then
        data_time=$(date +"%H:%M:%S %d-%m-%Y")
        echo "$data_time: Previous execution is still running. Skipping this cycle." >> "$error_log_file"
        continue
    fi

    echo "1" > "$execution_flag"
    data_time=$(date +"%H:%M:%S %d-%m-%Y")
    echo "$data_time: Executing scripts." >> "$success_log_file"

find "$initd_dir" -type f -executable | while read script; do
    script_name=$(basename "${script%.*}")
    script_log="$log_dir/$script_name.log"
    data_time=$(date +"%H:%M:%S %d-%m-%Y")
    
    echo "Starting $script_name at $data_time" >> "$execution_time_log_file"
    
    attempt=1
    while [ "$attempt" -le "$max_attempts" ]; do
        if timeout 120 sh "$script" >"$script_log" 2>&1; then
            echo "Successfully executed $script_name" >> "$success_log_file"
            echo "=====================================" >> "$success_log_file"
            break
        else
            echo "Attempt $attempt: Execution failed or timed out for $script_name" >> "$error_log_file"
            echo "=====================================" >> "$error_log_file"
            attempt=$((attempt + 1))
        fi
    done
    end_time=$(date +"%H:%M:%S %d-%m-%Y")

    # Log detajet e ekzekutimit të skriptit
    echo "End time: $end_time" >> "$execution_time_log_file"
    echo "=====================================" >> "$execution_time_log_file"
done
    
    # Kontrollo për ndërprerjen e skriptit
    if [ -f "$stop" ]; then
        echo "Stopping script at $data_time." >> "$error_log_file"
        break
    fi

    echo "0" > "$execution_flag"
done
