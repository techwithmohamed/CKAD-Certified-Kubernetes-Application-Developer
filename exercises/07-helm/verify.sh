#!/usr/bin/env bash
# Verify script for Exercise 07 — Helm
# Usage: bash exercises/07-helm/verify.sh

set -euo pipefail

NAMESPACE="exercise-07"
PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "true" ]; then
    echo "  ✓ $desc"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "Verifying Exercise 07 — Helm"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check helm is installed
helm_exists=$(command -v helm &>/dev/null && echo true || echo false)
check "Helm CLI is installed" "$helm_exists"

# Check bitnami repo
repo_exists=$(helm repo list 2>/dev/null | grep -c bitnami | tr -d ' ' || true)
check "Bitnami repo added" "$([ "$repo_exists" -ge 1 ] && echo true || echo false)"

# Check release exists
release_exists=$(helm list -n "$NAMESPACE" 2>/dev/null | grep -c "myredis" | tr -d ' ' || true)
check "Release 'myredis' exists" "$([ "$release_exists" -ge 1 ] && echo true || echo false)"

# Check release status
release_status=$(helm status myredis -n "$NAMESPACE" 2>/dev/null | grep -c "deployed" | tr -d ' ' || true)
check "Release is deployed" "$([ "$release_status" -ge 1 ] && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 07 PASSED!" || echo "❌ Exercise 07 has failures — review and retry."
