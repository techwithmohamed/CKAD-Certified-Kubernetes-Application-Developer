#!/usr/bin/env bash
# Verify script for Exercise 12 — DaemonSet
# Usage: bash exercises/12-daemonset/verify.sh

set -euo pipefail

NAMESPACE="exercise-12"
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

echo "Verifying Exercise 12 — DaemonSet"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

# Check DaemonSet exists
ds_exists=$(kubectl get daemonset log-collector -n "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "DaemonSet 'log-collector' exists" "$ds_exists"

# Check desired = available
desired=$(kubectl get daemonset log-collector -n "$NAMESPACE" -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null || echo 0)
available=$(kubectl get daemonset log-collector -n "$NAMESPACE" -o jsonpath='{.status.numberAvailable}' 2>/dev/null || echo -1)
check "All desired pods are available ($desired/$available)" "$([ "$desired" = "$available" ] && echo true || echo false)"

# Check node count matches pod count
node_count=$(kubectl get nodes --no-headers 2>/dev/null | wc -l || echo 0)
check "Pod count matches node count ($available nodes)" "$([ "$available" = "$node_count" ] && echo true || echo false)"

# Check host-logs volume mount
vol=$(kubectl get daemonset log-collector -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.volumes[0].hostPath.path}' 2>/dev/null || echo "")
check "hostPath /var/log mounted" "$([ "$vol" = "/var/log" ] && echo true || echo false)"

# Check resource requests
cpu_req=$(kubectl get daemonset log-collector -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null || echo "")
check "CPU request set" "$([ -n "$cpu_req" ] && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 12 PASSED!" || echo "❌ Exercise 12 has failures — review and retry."
