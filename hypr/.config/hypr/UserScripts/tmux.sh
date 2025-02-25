#!/bin/bash
# Name of the tmux session
SESSION="default"
term="/home/eirik/.local/kitty.app/bin/kitty"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  # Create a new detached tmux session with a window named 'neovim'
  tmux new-session -d -s "$SESSION" "nvim --listen /tmp/nvim.sock"
  
  # Create a second window (console) in the session.
  tmux new-window -t "$SESSION:" 
  
  # Optionally, select the first window.
  tmux select-window -t "$SESSION:0"
fi

# Launch Kitty with a dedicated class then attach to tmux.
$term --class=tmux_terminal bash -c "tmux attach-session -t '$SESSION'"
