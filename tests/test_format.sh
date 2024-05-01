#!/usr/bin/env bash
# tests/test_format.sh

source "$(dirname "$0")/../lib/format.sh"
PASS=0; FAIL=0

assert_contains() {
  if echo "$1" | grep -q "$2"; then
    echo "  ✔ $3"; (( PASS++ ))
  else
    echo "  ✖ $3 — '$2' not found in output"; (( FAIL++ ))
  fi
}

echo "=== format tests ==="

result=$(format_output '{"hello":"world"}' plain)
assert_contains "$result" "hello" "plain format outputs raw text"

result=$(format_output '{"hello":"world"}' json)
assert_contains "$result" '"hello"' "json format pretty-prints keys"

echo ""
echo "Passed: $PASS | Failed: $FAIL"
