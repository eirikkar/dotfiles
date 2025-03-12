#!/usr/bin/env bash
# A simple Bluetooth status script for Waybar.
if bluetoothctl info 2>/dev/null | grep -q "Connected: yes"; then
  echo "connected"
else
  echo "disconnected"
fi
