# Script to disable Power Save Mode
disable_power_save() {
    msg_on "Disabling Power Save Mode..."
    settings put global low_power 0
}
