#!/usr/bin/env bash
# lib/history.sh — Request history

HISTORY_FILE="${HOME}/.config/khizarb/history.log"

log_history() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$HISTORY_FILE"
}

show_history() {
  [[ -f "$HISTORY_FILE" ]] && cat "$HISTORY_FILE" || warn "No history yet."
}

clear_history() {
  rm -f "$HISTORY_FILE" && success "History cleared."
}
# show history
# clear history
