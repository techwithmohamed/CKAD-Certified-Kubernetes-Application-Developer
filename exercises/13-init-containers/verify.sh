#!/usr/bin/env bash
# Verify script for Exercise 13 — Init Containers
# Usage: bash exercises/13-init-containers/verify.sh

set -euo pipefail

NAMESPACE="exercise-13"
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

echo "Verifying Exercise 13 — Init Containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

# Task A — web-app with init container
pod_phase=$(kubectl get pod web-app -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
check "Pod 'web-app' is Running" "$([ "$pod_phase" = "Running" ] && echo true || echo false)"

init_count=$(kubectl get pod web-app -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null | wc -w || echo 0)
check "web-app has init container" "$([ "$init_count" -ge 1 ] && echo true || echo false)"

# Task B — multi-init
pod_b_phase=$(kubectl get pod multi-init -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
check "Pod 'multi-init' is Running" "$([ "$pod_b_phase" = "Running" ] && echo true || echo false)"

init_b_count=$(kubectl get pod multi-init -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null | wc -w || echo 0)
check "multi-init has 2 init containers" "$([ "$init_b_count" -eq 2 ] && echo true || echo false)"

# Check logs contain both config values
logs=$(kubectl logs multi-init -n "$NAMESPACE" -c app 2>/dev/null || echo "")
check "Logs contain CONFIG_READY=true" "$(echo "$logs" | grep -q 'CONFIG_READY=true' && echo true || echo false)"
check "Logs contain SCHEMA_READY=true" "$(echo "$logs" | grep -q 'SCHEMA_READY=true' && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 13 PASSED!" || echo "❌ Exercise 13 has failures — review and retry."
