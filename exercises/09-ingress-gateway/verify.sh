#!/usr/bin/env bash
# Verify script for Exercise 09 — Ingress + Gateway API
# Usage: bash exercises/09-ingress-gateway/verify.sh

set -euo pipefail

NAMESPACE="exercise-09"
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

echo "Verifying Exercise 09 — Ingress + Gateway API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

# Task A — Ingress
ingress_exists=$(kubectl get ingress -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l || echo 0)
check "Ingress resource exists" "$([ "$ingress_exists" -ge 1 ] && echo true || echo false)"

# Check Ingress has host-based routing
ingress_host=$(kubectl get ingress -n "$NAMESPACE" -o jsonpath='{.items[0].spec.rules[0].host}' 2>/dev/null || echo "")
check "Ingress has host rule" "$([ -n "$ingress_host" ] && echo true || echo false)"

# Task B — Gateway API (may not be available in all clusters)
httproute_exists=$(kubectl get httproute -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l || echo 0)
if [ "$httproute_exists" -ge 1 ]; then
  check "HTTPRoute resource exists" "true"
else
  echo "  ⚠ HTTPRoute not found (Gateway API CRDs may not be installed — skipping)"
fi

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 09 PASSED!" || echo "❌ Exercise 09 has failures — review and retry."
