#!/usr/bin/env bash
# Verify script for Exercise 08 — Probes
# Usage: bash exercises/08-probes/verify.sh

set -euo pipefail

NAMESPACE="exercise-08"
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

echo "Verifying Exercise 08 — Probes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers >/dev/null 2>&1 && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

POD_NAME="probe-test"
pod_phase=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
check "Pod '$POD_NAME' is Running" "$([ "$pod_phase" = "Running" ] && echo true || echo false)"

# Check liveness probe
liveness=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].livenessProbe}' 2>/dev/null || echo "")
check "Liveness probe configured" "$([ -n "$liveness" ] && echo true || echo false)"

# Check readiness probe
readiness=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].readinessProbe}' 2>/dev/null || echo "")
check "Readiness probe configured" "$([ -n "$readiness" ] && echo true || echo false)"

# Check startup probe
startup=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].startupProbe}' 2>/dev/null || echo "")
check "Startup probe configured" "$([ -n "$startup" ] && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 08 PASSED!" || echo "❌ Exercise 08 has failures — review and retry."
