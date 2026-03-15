#!/usr/bin/env bash
# Verify script for Exercise 01 — Pod Basics
# Usage: bash exercises/01-pod-basics/verify.sh

set -euo pipefail

NAMESPACE="exercise-01"
POD_NAME="web"
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

echo "Verifying Exercise 01 — Pod Basics"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check namespace exists
ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

# Check pod exists and is running
pod_phase=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
check "Pod '$POD_NAME' is Running" "$([ "$pod_phase" = "Running" ] && echo true || echo false)"

# Check image
pod_image=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].image}' 2>/dev/null || echo "")
check "Image is nginx:1.25" "$([ "$pod_image" = "nginx:1.25" ] && echo true || echo false)"

# Check labels
app_label=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.metadata.labels.app}' 2>/dev/null || echo "")
tier_label=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.metadata.labels.tier}' 2>/dev/null || echo "")
check "Label app=web" "$([ "$app_label" = "web" ] && echo true || echo false)"
check "Label tier=frontend" "$([ "$tier_label" = "frontend" ] && echo true || echo false)"

# Check resources
cpu_req=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null || echo "")
mem_req=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null || echo "")
cpu_lim=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null || echo "")
mem_lim=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null || echo "")
check "CPU request 100m" "$([ "$cpu_req" = "100m" ] && echo true || echo false)"
check "Memory request 128Mi" "$([ "$mem_req" = "128Mi" ] && echo true || echo false)"
check "CPU limit 250m" "$([ "$cpu_lim" = "250m" ] && echo true || echo false)"
check "Memory limit 256Mi" "$([ "$mem_lim" = "256Mi" ] && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 01 PASSED!" || echo "❌ Exercise 01 has failures — review and retry."
