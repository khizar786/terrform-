#!/usr/bin/env bash
# lib/fetch.sh — HTTP fetch with retry and rate-limit handling

fetch() {
  local url="$1"
  local method="${2:-GET}"
  local data="${3:-}"
  local headers="${4:-}"

  local curl_args=(-s --max-time "${TIMEOUT:-10}" -X "$method")
  [[ -n "$headers" ]] && curl_args+=(-H "$headers")
  [[ -n "$data"    ]] && curl_args+=(-d "$data" -H "Content-Type: application/json")

  local retries=0
  while [[ $retries -lt ${MAX_RETRIES:-3} ]]; do
    local response http_code body
    response=$(curl "${curl_args[@]}" -w "\n%{http_code}" "$url" 2>/dev/null) || true
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | head -n -1)

    if [[ "$http_code" =~ ^2 ]]; then
      echo "$body"; return 0
    elif [[ "$http_code" == "429" ]]; then
      warn "Rate limited. Retrying in 2s..."; sleep 2
    else
      warn "HTTP $http_code (attempt $((retries+1)))"
    fi
    (( retries++ ))
  done
  error "Request failed after ${MAX_RETRIES:-3} attempts."
}
