#!/usr/bin/env bash
# khizarb - A lightweight Bash CLI for fetching and querying APIs
# Author: Khiziar Bashir

set -euo pipefail

VERSION="1.0.0"
CONFIG_DIR="${HOME}/.config/khizarb"
CONFIG_FILE="${CONFIG_DIR}/config.env"
HISTORY_FILE="${CONFIG_DIR}/history.log"
CACHE_DIR="${CONFIG_DIR}/cache"

# ─── Colours ────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

# ─── Helpers ─────────────────────────────────────────────────────────────────
log()     { echo -e "${CYAN}[khizarb]${RESET} $*"; }
success() { echo -e "${GREEN}✔${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET} $*"; }
error()   { echo -e "${RED}✖ Error:${RESET} $*" >&2; exit 1; }

require() { command -v "$1" &>/dev/null || error "'$1' is required but not installed."; }

# ─── Init ────────────────────────────────────────────────────────────────────
init_config() {
  mkdir -p "$CONFIG_DIR" "$CACHE_DIR"
  if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<EOF
# khizarb configuration
DEFAULT_FORMAT=json
TIMEOUT=10
MAX_RETRIES=3
CACHE_TTL=300
EOF
    success "Config initialised at $CONFIG_FILE"
  fi
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
}

# ─── History ─────────────────────────────────────────────────────────────────
log_history() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$HISTORY_FILE"
}

show_history() {
  [[ -f "$HISTORY_FILE" ]] && cat "$HISTORY_FILE" || warn "No history yet."
}

clear_history() {
  rm -f "$HISTORY_FILE" && success "History cleared."
}

# ─── Cache ───────────────────────────────────────────────────────────────────
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
  local key; key=$(cache_key "$1")
  echo "$2" > "${CACHE_DIR}/${key}"
}

clear_cache() {
  rm -f "${CACHE_DIR:?}"/* && success "Cache cleared."
}

# ─── HTTP Fetch ──────────────────────────────────────────────────────────────
fetch() {
  local url="$1"
  local method="${2:-GET}"
  local data="${3:-}"
  local headers="${4:-}"

  require curl

  local curl_args=(-s --max-time "${TIMEOUT:-10}" -X "$method")
  [[ -n "$headers" ]] && curl_args+=(-H "$headers")
  [[ -n "$data"    ]] && curl_args+=(-d "$data" -H "Content-Type: application/json")

  local retries=0
  while [[ $retries -lt ${MAX_RETRIES:-3} ]]; do
    local response http_code
    response=$(curl "${curl_args[@]}" -w "\n%{http_code}" "$url" 2>/dev/null) || true
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | head -n -1)

    if [[ "$http_code" =~ ^2 ]]; then
      echo "$body"
      return 0
    elif [[ "$http_code" == "429" ]]; then
      warn "Rate limited. Waiting 2s..."
      sleep 2
    else
      warn "HTTP $http_code on attempt $((retries+1))"
    fi
    (( retries++ ))
  done

  error "Failed after ${MAX_RETRIES:-3} attempts (last HTTP $http_code)"
}

# ─── Format Output ───────────────────────────────────────────────────────────
format_output() {
  local data="$1"
  local fmt="${2:-${DEFAULT_FORMAT:-json}}"

  case "$fmt" in
    json)
      require jq
      echo "$data" | jq .
      ;;
    plain)
      echo "$data"
      ;;
    table)
      require jq
      echo "$data" | jq -r '
        if type == "array" then
          (.[0] | keys_unsorted) as $keys |
          ($keys | @tsv),
          (.[] | [.[$keys[]]] | @tsv)
        else
          to_entries[] | "\(.key)\t\(.value)"
        end
      ' | column -t
      ;;
    *)
      warn "Unknown format '$fmt', defaulting to plain."
      echo "$data"
      ;;
  esac
}

# ─── Built-in Endpoints ──────────────────────────────────────────────────────
cmd_get() {
  local url="$1"; shift
  local fmt="${1:-json}"
  local cached

  log "GET $url"
  log_history "GET $url"

  if cached=$(get_cache "$url"); then
    warn "Serving from cache."
    format_output "$cached" "$fmt"
    return
  fi

  local result; result=$(fetch "$url")
  set_cache "$url" "$result"
  format_output "$result" "$fmt"
}

cmd_post() {
  local url="$1"
  local data="$2"
  local fmt="${3:-json}"

  log "POST $url"
  log_history "POST $url"
  local result; result=$(fetch "$url" POST "$data")
  format_output "$result" "$fmt"
}

cmd_headers() {
  local url="$1"
  require curl
  log "HEAD $url"
  curl -sI "$url"
}

# ─── Presets ─────────────────────────────────────────────────────────────────
cmd_preset() {
  local name="$1"
  local fmt="${2:-json}"

  case "$name" in
    ip)        cmd_get "https://api.ipify.org?format=json" "$fmt" ;;
    weather)
      local city="${3:-London}"
      cmd_get "https://wttr.in/${city}?format=j1" "$fmt"
      ;;
    joke)      cmd_get "https://official-joke-api.appspot.com/random_joke" "$fmt" ;;
    dog)       cmd_get "https://dog.ceo/api/breeds/image/random" "$fmt" ;;
    crypto)
      local coin="${3:-bitcoin}"
      cmd_get "https://api.coingecko.com/api/v3/simple/price?ids=${coin}&vs_currencies=usd" "$fmt"
      ;;
    *)
      error "Unknown preset '$name'. Available: ip, weather, joke, dog, crypto"
      ;;
  esac
}

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}khizarb${RESET} v${VERSION} — Bash API client & data fetcher

${BOLD}USAGE${RESET}
  khizarb <command> [options]

${BOLD}COMMANDS${RESET}
  get <url> [format]          Fetch a URL (GET). Formats: json, plain, table
  post <url> <json> [format]  POST JSON data to a URL
  headers <url>               Show response headers
  preset <name> [format]      Run a built-in preset:
                                ip       — your public IP
                                weather  — weather (default: London)
                                joke     — random joke
                                dog      — random dog image
                                crypto   — crypto price (default: bitcoin)
  history                     Show request history
  history clear               Clear request history
  cache clear                 Clear response cache
  version                     Show version
  help                        Show this help

${BOLD}EXAMPLES${RESET}
  khizarb get https://api.github.com/users/khiziarb json
  khizarb post https://httpbin.org/post '{"name":"khizarb"}' table
  khizarb preset ip
  khizarb preset weather json London
  khizarb preset crypto plain ethereum
  khizarb history

EOF
}

# ─── Entry Point ─────────────────────────────────────────────────────────────
main() {
  init_config

  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
    get)      cmd_get "$@" ;;
    post)     cmd_post "$@" ;;
    headers)  cmd_headers "$@" ;;
    preset)   cmd_preset "$@" ;;
    history)
      [[ "${1:-}" == "clear" ]] && clear_history || show_history ;;
    cache)
      [[ "${1:-}" == "clear" ]] && clear_cache || warn "Usage: khizarb cache clear" ;;
    version)  echo "khizarb v${VERSION}" ;;
    help|--help|-h) usage ;;
    *)        error "Unknown command '$cmd'. Run 'khizarb help'." ;;
  esac
}

main "$@"
