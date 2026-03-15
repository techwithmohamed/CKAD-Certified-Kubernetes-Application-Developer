#!/usr/bin/env bash
# Verify script for Exercise 03 — ConfigMap + Secret Injection
# Usage: bash exercises/03-configmap-secret/verify.sh

set -euo pipefail

NAMESPACE="exercise-03"
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

echo "Verifying Exercise 03 — ConfigMap + Secret Injection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

# Check ConfigMap
cm_exists=$(kubectl get configmap app-config -n "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "ConfigMap 'app-config' exists" "$cm_exists"

# Check Secret
sec_exists=$(kubectl get secret app-secret -n "$NAMESPACE" --no-headers 2>/dev/null && echo true || echo false)
check "Secret 'app-secret' exists" "$sec_exists"

# Check pod
pod_phase=$(kubectl get pod config-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
check "Pod 'config-pod' is Running" "$([ "$pod_phase" = "Running" ] && echo true || echo false)"

# Check env vars from ConfigMap
env_val=$(kubectl exec config-pod -n "$NAMESPACE" -- env 2>/dev/null | grep -c "APP_ENV\|LOG_LEVEL" || echo 0)
check "ConfigMap env vars injected" "$([ "$env_val" -ge 1 ] && echo true || echo false)"

# Check secret volume mount
secret_mount=$(kubectl get pod config-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].volumeMounts[*].mountPath}' 2>/dev/null || echo "")
check "Secret mounted as volume" "$(echo "$secret_mount" | grep -q '/etc/secret' && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 03 PASSED!" || echo "❌ Exercise 03 has failures — review and retry."
