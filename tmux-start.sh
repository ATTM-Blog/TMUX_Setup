cat > ~/tmux-start.sh <<'SH'
#!/usr/bin/env bash
SESSION="main"

tmux has-session -t "$SESSION" 2>/dev/null && exec tmux attach -t "$SESSION"
tmux new-session -d -s "$SESSION" -n "Workspace"

# Split Top/Bottom (top = nnn, bottom = viewer)
tmux split-window -v -p 35 -t "$SESSION":0
tmux send-keys -t "$SESSION":0.1 'clear; echo "Viewer pane ready. Ctrl-b z = zoom."' C-m
tmux send-keys -t "$SESSION":0.0 "NNN_OPENER='$HOME/nnn-opener-tmux' nnn" C-m

# ---- Greyscale minimalist theme ----
tmux set -g status on
tmux set -g status-position bottom
tmux set -g status-interval 60
tmux set -g status-justify centre
tmux set -g status-left ''
tmux set -g status-right ''
tmux set -g status-style "bg=black,fg=brightwhite"
tmux set -g pane-border-style "fg=colour8"
tmux set -g pane-active-border-style "fg=brightwhite"
tmux set -g message-style "bg=black,fg=brightwhite"
tmux set -g mode-style "bg=black,fg=brightwhite"
tmux set -gu window-style
tmux set -gu window-active-style
tmux set -g default-terminal "screen-256color"
tmux set -ga terminal-overrides ",*:Tc"

# Status line (rotating sys-bar)
tmux set -g status-format[0] '#(/home/'"#(whoami)"'/sys-bar)'

# ---- Quick key bindings ----
tmux bind g run-shell '~/tmux-switch.sh git'
tmux bind l run-shell '~/tmux-switch.sh lazygit'
tmux bind m run-shell '~/tmux-switch.sh monitor'
tmux bind t run-shell '~/tmux-switch.sh term'
tmux bind e run-shell '~/tmux-switch.sh edit'
tmux bind v run-shell '~/tmux-switch.sh view'

tmux select-pane -t "$SESSION":0.0
exec tmux attach -t "$SESSION"
SH
chmod +x ~/tmux-start.sh
