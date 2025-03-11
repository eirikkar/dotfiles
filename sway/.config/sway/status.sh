#!/usr/bin/env bash
# This script outputs status information in the i3bar protocol format
# for swaybar. It shows the time, wifi, RAM usage, brightness, battery,
# volume, and bluetooth status.

# Print the protocol header.
echo '{"version":1, "click_events": false}'
echo "["

first=1

while true; do
  # Gather the current time and date in 24-hour format.
  current_time=$(date +"%H:%M")
  current_date=$(date +"%d-%m-%Y")

  # Get Wi-Fi connection name (adjust the interface if needed).
  wifi=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes" {print $2; exit}')
  if [ -z "$wifi" ]; then
    wifi="Disconnected"
  fi

  # Get RAM usage (used/total).
  ram=$(free -h | awk '/^Mem/ {print $3 " / " $2}')

  # Improved battery handling.
  battery_info=$(acpi -b | head -n 1)
  if [ -n "$battery_info" ]; then
    # Example output: "Battery 0: Charging, 72%, 00:40:00 until charged"
    battery_state=$(echo "$battery_info" | awk -F': ' '{print $2}' | cut -d, -f1)
    battery_percent=$(echo "$battery_info" | awk -F', ' '{print $2}')
    # Choose an icon based on whether the battery is charging.
    if echo "$battery_state" | grep -qi "Charging"; then
      battery=" $battery_percent"
    else
      battery="$battery_percent"
    fi
  else
    battery="N/A"
  fi

  # Get the current volume level (this command may vary by system).
  volume=$(amixer get Master | tail -n1 | awk -F'[][]' '{print $2}')

  # Get screen brightness (adjust the backlight path if needed).
  if [ -f /sys/class/backlight/intel_backlight/brightness ]; then
    brightness=$(cat /sys/class/backlight/intel_backlight/brightness)
    max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
    brightness_percent=$(( 100 * brightness / max_brightness ))
  else
    brightness_percent="N/A"
  fi

  # Check Bluetooth status.
  if bluetoothctl info 2>/dev/null | grep -q "Connected: yes"; then
    bluetooth="Connected"
  else
    bluetooth="Disconnected"
  fi

  # Build a JSON array of status items.
  # You can adjust the icons and text as desired.
  status_line=$(printf '[{"full_text": "Time: %s %s"}, {"full_text": "WiFi: %s"}, {"full_text": "RAM: %s"}, {"full_text": "Brightness: %s%%"}, {"full_text": "Battery: %s"}, {"full_text": "Volume: %s"}, {"full_text": "Bluetooth: %s"}]' \
    "$current_time" "$current_date" "$wifi" "$ram" "$brightness_percent" "$battery" "$volume" "$bluetooth")
  
  # Output the status line with a preceding comma if not the first.
  if [ $first -eq 1 ]; then
    echo "$status_line"
    first=0
  else
    echo ",$status_line"
  fi

  sleep 1  # Update every second; adjust as needed.
done
