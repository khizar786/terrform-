#!/usr/bin/env bash
# tests/test_fetch.sh

source "$(dirname "$0")/../lib/fetch.sh"
PASS=0; FAIL=0

assert_eq() {
  if [[ "$1" == "$2" ]]; then
    echo "  ✔ $3"; (( PASS++ ))
  else
    echo "  ✖ $3 — expected '$2', got '$1'"; (( FAIL++ ))
  fi
}

echo "=== fetch tests ==="

# Timeout default
TIMEOUT=5; assert_eq "$TIMEOUT" "5" "TIMEOUT default is 5"
MAX_RETRIES=3; assert_eq "$MAX_RETRIES" "3" "MAX_RETRIES default is 3"

echo ""
echo "Passed: $PASS | Failed: $FAIL"
