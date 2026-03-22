#!/usr/bin/env bash
# Verify script for Exercise 05 — NetworkPolicy
# Usage: bash exercises/05-networkpolicy/verify.sh

set -euo pipefail

NAMESPACE="exercise-05"
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

echo "Verifying Exercise 05 — NetworkPolicy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers >/dev/null 2>&1 && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

# Check NetworkPolicy exists
np_exists=$(kubectl get networkpolicy -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l | tr -d ' ' || true)
check "NetworkPolicy exists" "$([ "$np_exists" -ge 1 ] && echo true || echo false)"

# Check policy types include Ingress
policy_types=$(kubectl get networkpolicy -n "$NAMESPACE" -o jsonpath='{.items[0].spec.policyTypes[*]}' 2>/dev/null || echo "")
check "Policy includes Ingress type" "$(echo "$policy_types" | grep -q 'Ingress' && echo true || echo false)"

# Check policy types include Egress
check "Policy includes Egress type" "$(echo "$policy_types" | grep -q 'Egress' && echo true || echo false)"

# Check DNS egress rule (UDP 53)
egress_port=$(kubectl get networkpolicy -n "$NAMESPACE" -o json 2>/dev/null | grep -c '"port": 53' | tr -d ' ' || true)
check "DNS egress rule (port 53) present" "$([ "$egress_port" -ge 1 ] && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 05 PASSED!" || echo "❌ Exercise 05 has failures — review and retry."
