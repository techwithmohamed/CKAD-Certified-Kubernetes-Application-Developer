#!/usr/bin/env bash
# Verify script for Exercise 04 — RBAC
# Usage: bash exercises/04-rbac/verify.sh

set -euo pipefail

NAMESPACE="exercise-04"
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

echo "Verifying Exercise 04 — RBAC"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ns_exists=$(kubectl get namespace "$NAMESPACE" --no-headers >/dev/null 2>&1 && echo true || echo false)
check "Namespace '$NAMESPACE' exists" "$ns_exists"

# Check ServiceAccount
sa_exists=$(kubectl get serviceaccount app-sa -n "$NAMESPACE" --no-headers >/dev/null 2>&1 && echo true || echo false)
check "ServiceAccount 'app-sa' exists" "$sa_exists"

# Check Role
role_exists=$(kubectl get role pod-manager -n "$NAMESPACE" --no-headers >/dev/null 2>&1 && echo true || echo false)
check "Role 'pod-manager' exists" "$role_exists"

# Check RoleBinding
rb_exists=$(kubectl get rolebinding app-sa-binding -n "$NAMESPACE" --no-headers >/dev/null 2>&1 && echo true || echo false)
check "RoleBinding 'app-sa-binding' exists" "$rb_exists"

# Check permissions
can_get=$(kubectl auth can-i get pods --as=system:serviceaccount:"$NAMESPACE":app-sa -n "$NAMESPACE" 2>/dev/null || true)
check "app-sa can get pods" "$([ "$can_get" = "yes" ] && echo true || echo false)"

can_delete=$(kubectl auth can-i delete pods --as=system:serviceaccount:"$NAMESPACE":app-sa -n "$NAMESPACE" 2>/dev/null || true)
check "app-sa cannot delete pods" "$([ "$can_delete" = "no" ] && echo true || echo false)"

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise 04 PASSED!" || echo "❌ Exercise 04 has failures — review and retry."
