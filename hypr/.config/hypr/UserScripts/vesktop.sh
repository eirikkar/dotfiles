#!/bin/bash
# Switch to workspace 7 before starting vesktop
hyprctl dispatch workspace 7

# Start vesktop in the background
vesktop &

# Wait for the vesktop client to appear (might initially be the loading screen)
while ! hyprctl clients | grep -iq "vesktop"; do
  sleep 0.5
done

# Wait until the main window is detected (checks for "initialTitle: Discord")
while ! hyprctl clients | grep -iq "initialTitle: Discord"; do
  sleep 0.5
done

# Optionally, add a brief sleep for any additional transition
sleep 0.5

# Switch back to workspace 1 after the main window loads
hyprctl dispatch workspace 1
