#!/usr/bin/env bash
# lib/cache.sh — Response caching with TTL

CACHE_DIR="${HOME}/.config/khizarb/cache"

cache_key() { echo "$1" | md5sum | cut -d' ' -f1; }

get_cache() {
  local key; key=$(cache_key "$1")
  local file="${CACHE_DIR}/${key}"
  if [[ -f "$file" ]]; then
    local age=$(( $(date +%s) - $(stat -c %Y "$file") ))
    [[ $age -lt ${CACHE_TTL:-300} ]] && { cat "$file"; return 0; }
  fi
  return 1
}

set_cache() {
  mkdir -p "$CACHE_DIR"
  local key; key=$(cache_key "$1")
  echo "$2" > "${CACHE_DIR}/${key}"
}

clear_cache() {
  rm -f "${CACHE_DIR:?}"/*
  success "Cache cleared."
}
