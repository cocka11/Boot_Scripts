# Script to enable Power Save Mode
enable_power_save() {
    msg_off "Enabling Power Save Mode..."
    settings put global low_power 1
}
enable_power_save
