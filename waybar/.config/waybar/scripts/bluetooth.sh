#!/bin/bash

blueman-applet &
if bluetoothctl show | grep -q "Powered: yes"; then
    connected_devices=$(bluetoothctl devices Connected | wc -l)
    if [ $connected_devices -gt 0 ]; then
        echo "󰂱 $connected_devices"
        echo "Connected to $connected_devices devices"
    else
        echo "󰂯"
        echo "No devices connected"
    fi
else
    echo "󰂲"
    echo "Bluetooth off"
fi
