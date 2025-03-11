#!/usr/bin/env bash
# This script outputs status information in the i3bar protocol format for swaybar.
# It shows: time, WiFi, RAM, brightness, battery, volume, CPU usage, temperature, and Bluetooth status.

# Print the i3bar protocol header.
echo '{"version":1, "click_events": false}'
echo "["

# Initialize CPU statistics.
read -r -a cpu_fields < /proc/stat
prev_total=0
for i in {1..8}; do
  prev_total=$(( prev_total + cpu_fields[i] ))
done
prev_idle=${cpu_fields[4]}

first=1

while true; do
  # Current time and date.
  current_time=$(date +"%H:%M")
  current_date=$(date +"%d-%m-%Y")

  # Get Wi-Fi connection name (adjust the interface if needed).
  wifi=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes" {print $2; exit}')
  if [ -z "$wifi" ]; then
    wifi="Disconnected"
  fi

  # Get RAM usage (used / total).
  ram=$(free -h | awk '/^Mem/ {print $3 " / " $2}')

  # Battery information.
  battery_info=$(acpi -b | head -n 1)
  if [ -n "$battery_info" ]; then
    battery_state=$(echo "$battery_info" | awk -F': ' '{print $2}' | cut -d, -f1 | xargs)
    battery_percent=$(echo "$battery_info" | awk -F', ' '{print $2}')
    if [ "$battery_state" = "Charging" ]; then
      battery=" $battery_percent"
    else
      battery="$battery_percent"
    fi
  else
    battery="N/A"
  fi

  # Get volume (this command may need adjustment for your system).
  volume=$(amixer get Master | tail -n1 | awk -F'[][]' '{print $2}')

  # Brightness retrieval. Dynamically detect the backlight device.
  if [ -f /sys/class/backlight/dp_aux_backlight/brightness ]; then
    brightness=$(cat /sys/class/backlight/dp_aux_backlight/brightness)
    max_brightness=$(cat /sys/class/backlight/dp_aux_backlight/max_brightness)
    brightness_percent=$(( 100 * brightness / max_brightness ))
  else
    brightness_percent="N/A"
  fi

  # CPU usage calculation.
  read -r -a cpu_fields < /proc/stat
  total=0
  for i in {1..8}; do
    total=$(( total + cpu_fields[i] ))
  done
  idle=${cpu_fields[4]}
  dtotal=$(( total - prev_total ))
  didle=$(( idle - prev_idle ))
  if [ "$dtotal" -gt 0 ]; then
    delta_busy=$(( dtotal - didle ))
    cpu_usage=$(awk "BEGIN {printf \"%0.f\", (100*$delta_busy/$dtotal)}")
  else
    cpu_usage=0
  fi
  prev_total=$total
  prev_idle=$idle

  # Temperature retrieval.
  # Uses sed to extract a temperature value (assumes a format like "+47.0°C").
  temp=$(sensors | sed -n 's/.*+\([0-9.]\+\)°C.*/\1/p' | head -n 1)
  if [ -z "$temp" ]; then
    temp="N/A"
  fi

  # Bluetooth status.
  if bluetoothctl info 2>/dev/null | grep -q "Connected: yes"; then
    bluetooth="Connected"
  else
    bluetooth="Disconnected"
  fi

  # Construct a JSON array of status items.
  status_line=$(printf '[{"full_text": "Time: %s %s"}, {"full_text": "WiFi: %s"}, {"full_text": "RAM: %s"}, {"full_text": "Brightness: %s%%"}, {"full_text": "Battery: %s"}, {"full_text": "Volume: %s"}, {"full_text": "CPU: %s%%"}, {"full_text": "Temp: %s°C"}, {"full_text": "Bluetooth: %s"}]' \
    "$current_time" "$current_date" "$wifi" "$ram" "$brightness_percent" "$battery" "$volume" "$cpu_usage" "$temp" "$bluetooth")

  if [ $first -eq 1 ]; then
    echo "$status_line"
    first=0
  else
    echo ",$status_line"
  fi

  sleep 1
done
