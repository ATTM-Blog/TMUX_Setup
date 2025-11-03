cat > ~/tmux-switch.sh <<'SH'
#!/usr/bin/env bash
# Swap the bottom pane to a chosen TUI command.
PANE=$(tmux list-panes -F '#{pane_index} #{pane_id} #{pane_top}' |
       sort -k3n | head -n1 | awk '{print $2}')
case "$1" in
  git)     cmd="gitui" ;;
  lazygit) cmd="lazygit" ;;
  monitor) cmd="btop || htop" ;;
  term)    cmd="bash" ;;
  edit)    cmd="vim" ;;
  view)    cmd="less -S" ;;
  *) echo "Usage: tmux-switch.sh [git|lazygit|monitor|term|edit|view]"; exit 1 ;;
esac
tmux send-keys -t "$PANE" C-c "clear; $cmd" C-m
SH
chmod +x ~/tmux-switch.sh
