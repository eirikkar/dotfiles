#!/bin/bash

# Qualcomm battery and AC adapter paths
battery_path="/sys/class/power_supply/qcom-battmgr-bat"
ac_path="/sys/class/power_supply/qcom-battmgr-ac"
usb_path="/sys/class/power_supply/qcom-battmgr-usb"

if [ ! -d "$battery_path" ]; then
    echo '{"text": "No Battery", "tooltip": "Battery path not found", "class": "no-battery"}'
    exit 0
fi

# Check for energy values to calculate capacity
energy_now_file="$battery_path/energy_now"
energy_full_file="$battery_path/energy_full"
status_file="$battery_path/status"

if [ ! -f "$energy_now_file" ] || [ ! -f "$energy_full_file" ] || [ ! -f "$status_file" ]; then
    echo '{"text": "Battery Error", "tooltip": "Required battery files not found", "class": "battery-error"}'
    exit 0
fi

# Calculate capacity percentage
energy_now=$(cat "$energy_now_file")
energy_full=$(cat "$energy_full_file")
capacity=$(echo "scale=0; $energy_now * 100 / $energy_full" | bc)

status=$(cat "$status_file")
tooltip="Battery: $capacity%\\nStatus: $status"
class=""

# Get AC adapter status
ac_online=0
if [ -f "$ac_path/online" ]; then
    ac_online=$(cat "$ac_path/online")
fi

# Get USB connection status
usb_online=0
if [ -f "$usb_path/online" ]; then
    usb_online=$(cat "$usb_path/online")
fi

# Define icons based on capacity
if [ "$capacity" -ge 90 ]; then
    icon="󰁹"
elif [ "$capacity" -ge 80 ]; then
    icon="󰂂"
elif [ "$capacity" -ge 70 ]; then
    icon="󰂁"
elif [ "$capacity" -ge 60 ]; then
    icon="󰂀"
elif [ "$capacity" -ge 50 ]; then
    icon="󰁿"
elif [ "$capacity" -ge 40 ]; then
    icon="󰁾"
elif [ "$capacity" -ge 30 ]; then
    icon="󰁽"
elif [ "$capacity" -ge 20 ]; then
    icon="󰁼"
elif [ "$capacity" -ge 10 ]; then
    icon="󰁻"
else
    icon="󰁺"
    class="critical"
fi

text="$icon $capacity%"

# Check if power_now file exists
power_now_file="$battery_path/power_now"
if [ -f "$power_now_file" ]; then
    power_val=$(cat "$power_now_file")
    
    # Convert to watts
    wattage=$(echo "scale=1; $power_val / 1000000" | bc)
    
    # Check if charging
    if [ "$status" = "Charging" ] || [ "$ac_online" = "1" ] || [ "$usb_online" = "1" ]; then
        icon="󰂄"
        class="charging"
        text="$icon $capacity% ($wattage W)"
        tooltip="${tooltip}\\nPower: $wattage W (charging)"
    else
        text="$icon $capacity% ($wattage W)"
        tooltip="${tooltip}\\nPower: $wattage W (discharging)"
    fi
elif [ "$status" = "Charging" ] || [ "$ac_online" = "1" ] || [ "$usb_online" = "1" ]; then
    icon="󰂄"
    class="charging"
fi

if [ "$status" = "Full" ]; then
    icon="󰚥"
    class="plugged"
    text="$icon $capacity%"
fi

# Add debug info
tooltip="${tooltip}\\nEnergy now: $energy_now µWh\\nEnergy full: $energy_full µWh\\nAC online: $ac_online\\nUSB online: $usb_online"
tooltip=$(echo "$tooltip" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
