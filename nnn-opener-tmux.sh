cat > ~/nnn-opener-tmux <<'SH'
#!/usr/bin/env bash
# Opens selected files from nnn in the bottom tmux pane.
PANE=$(tmux list-panes -F '#{pane_index} #{pane_id} #{pane_top}' |
       sort -k3n | head -n1 | awk '{print $2}')
open_one(){ f="$1"; [ -d "$f" ] && return
  if command -v vim >/dev/null 2>&1; then
    tmux send-keys -t "$PANE" "vim -- \"$f\"" C-m
  else
    tmux send-keys -t "$PANE" "less -S -- \"$f\"" C-m
  fi
}
if [ $# -gt 0 ]; then for f in "$@"; do open_one "$f"; done
else while IFS= read -r f; do open_one "$f"; done; fi
SH
chmod +x ~/nnn-opener-tmux
