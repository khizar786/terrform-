#!/usr/bin/env bash
# tests/test_cache.sh

export HOME="/tmp/khizarb_test_$$"
source "$(dirname "$0")/../lib/cache.sh"
PASS=0; FAIL=0

assert_eq() {
  if [[ "$1" == "$2" ]]; then
    echo "  ✔ $3"; (( PASS++ ))
  else
    echo "  ✖ $3 — expected '$2', got '$1'"; (( FAIL++ ))
  fi
}

echo "=== cache tests ==="

# cache miss
get_cache "http://example.com" &>/dev/null && echo "  ✖ Expected cache miss" && (( FAIL++ )) || { echo "  ✔ Cache miss on empty cache"; (( PASS++ )); }

# cache set and hit
set_cache "http://example.com" '{"test":true}'
result=$(get_cache "http://example.com")
assert_eq "$result" '{"test":true}' "Cache hit returns correct value"

# cleanup
rm -rf "$HOME"
echo ""
echo "Passed: $PASS | Failed: $FAIL"
# edge case
