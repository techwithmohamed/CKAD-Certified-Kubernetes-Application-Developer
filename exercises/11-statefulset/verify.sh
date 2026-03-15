#!/usr/bin/env bash
# Verify script for Exercise 11 — StatefulSet
# Usage: bash exercises/11-statefulset/verify.sh

set -euo pipefail

NAMESPACE="exercise-11"
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

echo "Verifying Exercise 11 — StatefulSet"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

# Check headless service
svc_cluster_ip=$(kubectl get service db-headless -n "$NAMESPACE" -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "")
check "Headless Service 'db-headless' exists (clusterIP: None)" "$([ "$svc_cluster_ip" = "None" ] && echo true || echo false)"

# Check StatefulSet
sts_exists=$(kubectl get statefulset db -n "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "StatefulSet 'db' exists" "$sts_exists"

replicas=$(kubectl get statefulset db -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo 0)
check "Replicas is 3" "$([ "$replicas" = "3" ] && echo true || echo false)"

svc_name=$(kubectl get statefulset db -n "$NAMESPACE" -o jsonpath='{.spec.serviceName}' 2>/dev/null || echo "")
check "serviceName is 'db-headless'" "$([ "$svc_name" = "db-headless" ] && echo true || echo false)"

# Check pods have stable names
pod0=$(kubectl get pod db-0 -n "$NAMESPACE" -o jsonpath='{.metadata.name}' 2>/dev/null || echo "")
pod1=$(kubectl get pod db-1 -n "$NAMESPACE" -o jsonpath='{.metadata.name}' 2>/dev/null || echo "")
pod2=$(kubectl get pod db-2 -n "$NAMESPACE" -o jsonpath='{.metadata.name}' 2>/dev/null || echo "")
check "Pod db-0 exists" "$([ "$pod0" = "db-0" ] && echo true || echo false)"
check "Pod db-1 exists" "$([ "$pod1" = "db-1" ] && echo true || echo false)"
check "Pod db-2 exists" "$([ "$pod2" = "db-2" ] && echo true || echo false)"

# Check PVCs
pvc0=$(kubectl get pvc data-db-0 -n "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
pvc1=$(kubectl get pvc data-db-1 -n "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
pvc2=$(kubectl get pvc data-db-2 -n "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "PVC data-db-0 exists" "$pvc0"
check "PVC data-db-1 exists" "$pvc1"
check "PVC data-db-2 exists" "$pvc2"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 11 PASSED!" || echo "❌ Exercise 11 has failures — review and retry."
