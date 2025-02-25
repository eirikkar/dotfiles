#!/bin/bash
# Name of the tmux session
SESSION="default"

# Check if the session already exists. If it doesn't, create it.
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  # Create a new detached tmux session with the first window named "neovim"
  tmux new-session -d -s "$SESSION" -n neovim
  
  # Create a second window (tab) in the session named "console"
  tmux new-window -t "$SESSION:" -n console
  
  # Optionally, select the first window so that it’s what you see on attach
  tmux select-window -t "$SESSION:0"
fi

# Launch kitty and attach to the tmux session
kitty --class=tmux_terminal bash -c "tmux attach-session -t '$SESSION'"
