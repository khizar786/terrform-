#!/usr/bin/env bash
# lib/format.sh — Output formatters

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
# table mode
