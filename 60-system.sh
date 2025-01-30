disable_usb_power_savings() {
    local device=$1
    if [[ -n "$device" ]]; then
        if [[ -d "/sys/bus/usb/devices/$device" ]]; then
            echo "Disabling power savings for device: $device"
            echo "on" > "/sys/bus/usb/devices/$device/power/control"
        else
            echo "Device $device not found!"
            exit 1
        fi
    else
        echo "Disabling USB power savings for all devices..."
        for usb_device in /sys/bus/usb/devices/*/power/control; do
            echo "on" > "$usb_device"
        done
    fi
}

create_alias "disable_usb_power_savings" "disable_usb_power_savings" "yes" "Disable USB power savings for all devices or a specific device."