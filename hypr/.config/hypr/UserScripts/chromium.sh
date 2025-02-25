#!/bin/bash
# Define your URLs
URL1="https://music.youtube.com"
URL2="https://t3.chat/chat"
URL3="https://www.github.com/eirikkar"

# Launch Chromium with a new window and the predefined tabs.
chromium --new-window "$URL1" "$URL2" "$URL3"
