#!/usr/bin/env bash
# Verify script for Exercise 10 — SecurityContext + PVC
# Usage: bash exercises/10-security-pvc/verify.sh

set -euo pipefail

NAMESPACE="exercise-10"
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

echo "Verifying Exercise 10 — SecurityContext + PVC"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

# Task A — SecurityContext
POD_A="locked-down"
pod_phase=$(kubectl get pod "$POD_A" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
check "Pod '$POD_A' is Running" "$([ "$pod_phase" = "Running" ] && echo true || echo false)"

run_as_user=$(kubectl get pod "$POD_A" -n "$NAMESPACE" -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null || echo "")
check "runAsUser is 1000" "$([ "$run_as_user" = "1000" ] && echo true || echo false)"

fs_group=$(kubectl get pod "$POD_A" -n "$NAMESPACE" -o jsonpath='{.spec.securityContext.fsGroup}' 2>/dev/null || echo "")
check "fsGroup is 2000" "$([ "$fs_group" = "2000" ] && echo true || echo false)"

read_only=$(kubectl get pod "$POD_A" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null || echo "")
check "readOnlyRootFilesystem is true" "$([ "$read_only" = "true" ] && echo true || echo false)"

no_priv=$(kubectl get pod "$POD_A" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null || echo "")
check "allowPrivilegeEscalation is false" "$([ "$no_priv" = "false" ] && echo true || echo false)"

# Task B — PVC
pvc_exists=$(kubectl get pvc data-pvc -n "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "PVC 'data-pvc' exists" "$pvc_exists"

POD_B="writer"
pod_b_phase=$(kubectl get pod "$POD_B" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
check "Pod '$POD_B' is Running" "$([ "$pod_b_phase" = "Running" ] && echo true || echo false)"

vol_mount=$(kubectl get pod "$POD_B" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null || echo "")
check "PVC mounted at /data" "$([ "$vol_mount" = "/data" ] && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 10 PASSED!" || echo "❌ Exercise 10 has failures — review and retry."
