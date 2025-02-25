#!/bin/bash
# Name of the tmux session
SESSION="default"

# Create a new detached tmux session with the first window.
tmux new-session -d -s "$SESSION" -n neovim

# Create a second window (tab) in the session.
tmux new-window -t "$SESSION:" -n console

# (Optional) Select the first window so that it’s what you see on attach.
tmux select-window -t "$SESSION:0"

# Launch kitty and attach to the tmux session.
kitty --class=kitty_tmux bash -c "tmux attach-session -t '$SESSION'"
