#!/usr/bin/env bash
# Verify script for Exercise 02 — Multi-Container Pod (Sidecar)
# Usage: bash exercises/02-multi-container-pod/verify.sh

set -euo pipefail

NAMESPACE="exercise-02"
POD_NAME="app-with-sidecar"
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

echo "Verifying Exercise 02 — Multi-Container Pod (Sidecar)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers >/dev/null 2>&1 && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

pod_phase=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
check "Pod '$POD_NAME' is Running" "$([ "$pod_phase" = "Running" ] && echo true || echo false)"

# Check container count
container_count=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].name} {.spec.initContainers[*].name}' 2>/dev/null | wc -w | tr -d ' ' || true)
check "Pod has 2 containers" "$([ "$container_count" -eq 2 ] && echo true || echo false)"

# Check container names
containers=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].name} {.spec.initContainers[*].name}' 2>/dev/null || echo "")
check "Container 'app' exists" "$(echo "$containers" | grep -q 'app' && echo true || echo false)"
check "Container 'log-agent' exists" "$(echo "$containers" | grep -q 'log-agent' && echo true || echo false)"

# Check shared volume
vol_count=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.volumes[*].name}' 2>/dev/null | wc -w | tr -d ' ' || true)
check "Shared volume exists" "$([ "$vol_count" -ge 1 ] && echo true || echo false)"

# Check sidecar is producing logs
sidecar_logs=$(kubectl logs "$POD_NAME" -n "$NAMESPACE" -c log-agent --tail=1 2>/dev/null || echo "")
check "Sidecar is streaming logs" "$([ -n "$sidecar_logs" ] && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 02 PASSED!" || echo "❌ Exercise 02 has failures — review and retry."
