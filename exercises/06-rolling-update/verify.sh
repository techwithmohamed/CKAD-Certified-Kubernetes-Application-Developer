#!/usr/bin/env bash
# Verify script for Exercise 06 — Deployment + Rolling Update + Rollback
# Usage: bash exercises/06-rolling-update/verify.sh

set -euo pipefail

NAMESPACE="exercise-06"
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

echo "Verifying Exercise 06 — Deployment + Rolling Update + Rollback"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers >/dev/null 2>&1 && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

# Check deployment exists
deploy_exists=$(kubectl get deployment webapp -n "$NAMESPACE" --no-headers >/dev/null 2>&1 && echo true || echo false)
check "Deployment 'webapp' exists" "$deploy_exists"

# Check replicas
replicas=$(kubectl get deployment webapp -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo 0)
check "Replicas is 4" "$([ "$replicas" = "4" ] && echo true || echo false)"

# Check strategy
strategy=$(kubectl get deployment webapp -n "$NAMESPACE" -o jsonpath='{.spec.strategy.type}' 2>/dev/null || echo "")
check "Strategy is RollingUpdate" "$([ "$strategy" = "RollingUpdate" ] && echo true || echo false)"

# Check maxSurge
max_surge=$(kubectl get deployment webapp -n "$NAMESPACE" -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null || echo "")
check "maxSurge is 1" "$([ "$max_surge" = "1" ] && echo true || echo false)"

# Check maxUnavailable
max_unavail=$(kubectl get deployment webapp -n "$NAMESPACE" -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null || echo "")
check "maxUnavailable is 0" "$([ "$max_unavail" = "0" ] && echo true || echo false)"

# Check rollout history has multiple revisions
rev_count=$(kubectl rollout history deployment/webapp -n "$NAMESPACE" 2>/dev/null | grep -c "^[0-9]" | tr -d ' ' || true)
check "Rollout history has revisions" "$([ "$rev_count" -ge 1 ] && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 06 PASSED!" || echo "❌ Exercise 06 has failures — review and retry."
