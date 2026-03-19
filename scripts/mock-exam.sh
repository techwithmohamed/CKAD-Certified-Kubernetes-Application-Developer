#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# CKAD Mock Exam — 17 Questions, Timed, Auto-Scored
# ═══════════════════════════════════════════════════════════════
# Usage: bash scripts/mock-exam.sh
# Requires: a running Kubernetes cluster (kind, minikube, or remote)
#
# Simulates real exam conditions:
#   - 2-hour time limit
#   - Questions presented one at a time
#   - Auto-verification after each answer
#   - Final score with domain breakdown
#
# Source: https://github.com/techwithmohamed/CKAD-Certified-Kubernetes-Application-Developer

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

EXAM_DURATION=7200  # 2 hours in seconds
PASS_SCORE=66

# Domain scores
declare -A domain_score
declare -A domain_total
domain_score[design]=0; domain_total[design]=0
domain_score[deploy]=0; domain_total[deploy]=0
domain_score[observe]=0; domain_total[observe]=0
domain_score[security]=0; domain_total[security]=0
domain_score[networking]=0; domain_total[networking]=0

total_score=0
total_possible=0
questions_attempted=0
questions_correct=0
flagged=""

start_time=$(date +%s)

time_remaining() {
  local now=$(date +%s)
  local elapsed=$((now - start_time))
  local remaining=$((EXAM_DURATION - elapsed))
  if [ "$remaining" -le 0 ]; then
    echo "0:00"
    return 1
  fi
  printf "%d:%02d" $((remaining / 60)) $((remaining % 60))
}

print_header() {
  clear
  echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║         CKAD MOCK EXAM — 17 Questions, 2 Hours          ║${NC}"
  echo -e "${BOLD}║         Passing Score: ${PASS_SCORE}%                               ║${NC}"
  echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
  local remaining
  remaining=$(time_remaining) || true
  echo -e "  ${CYAN}Time Remaining: ${remaining}  |  Score: ${total_score}/${total_possible}${NC}"
  echo ""
}

wait_for_answer() {
  local q_num="$1"
  local weight="$2"
  echo ""
  echo -e "  ${DIM}Commands: [Enter] = verify  |  [s] = skip  |  [f] = flag for later  |  [q] = end exam${NC}"
  echo -n "  > "
  read -r cmd

  case "$cmd" in
    s|S|skip)
      echo -e "  ${YELLOW}⏭  Skipped Q${q_num} (${weight}%)${NC}"
      return 1
      ;;
    f|F|flag)
      flagged="${flagged} Q${q_num}"
      echo -e "  ${YELLOW}🚩 Flagged Q${q_num} for review${NC}"
      return 1
      ;;
    q|Q|quit)
      return 2
      ;;
    *)
      return 0
      ;;
  esac
}

verify_and_score() {
  local q_num="$1"
  local weight="$2"
  local domain="$3"
  local check_cmd="$4"

  questions_attempted=$((questions_attempted + 1))
  total_possible=$((total_possible + weight))
  domain_total[$domain]=$((${domain_total[$domain]} + weight))

  if eval "$check_cmd" &>/dev/null; then
    echo -e "  ${GREEN}✓ Q${q_num} CORRECT (+${weight}%)${NC}"
    total_score=$((total_score + weight))
    domain_score[$domain]=$((${domain_score[$domain]} + weight))
    questions_correct=$((questions_correct + 1))
  else
    echo -e "  ${RED}✗ Q${q_num} INCORRECT (0%)${NC}"
  fi
}

pause() {
  echo ""
  echo -e "  ${DIM}Press Enter to continue to next question...${NC}"
  read -r
}

cleanup() {
  echo ""
  echo -e "${YELLOW}Cleaning up mock exam namespaces...${NC}"
  for ns in mock-q1 mock-q2 mock-q3 mock-q4 mock-q5 mock-q6 mock-q7 \
            mock-q8 mock-q9 mock-q10 mock-q11 mock-q12 mock-q13 \
            mock-q14 mock-q15 mock-q16 mock-q17; do
    kubectl delete namespace "$ns" --ignore-not-found --force --grace-period=0 2>/dev/null &
  done
  wait
  echo -e "${GREEN}Cleanup complete.${NC}"
}

show_results() {
  local pct=0
  if [ "$total_possible" -gt 0 ]; then
    pct=$((total_score * 100 / total_possible))
  fi

  echo ""
  echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║                    EXAM RESULTS                          ║${NC}"
  echo -e "${BOLD}╠═══════════════════════════════════════════════════════════╣${NC}"
  printf "${BOLD}║  %-55s ║${NC}\n" "Questions Attempted: ${questions_attempted}/17"
  printf "${BOLD}║  %-55s ║${NC}\n" "Questions Correct: ${questions_correct}"
  printf "${BOLD}║  %-55s ║${NC}\n" "Score: ${total_score}/${total_possible} weighted points"

  local elapsed=$(( $(date +%s) - start_time ))
  printf "${BOLD}║  %-55s ║${NC}\n" "Time Used: $((elapsed / 60))m $((elapsed % 60))s"

  echo -e "${BOLD}╠═══════════════════════════════════════════════════════════╣${NC}"
  echo -e "${BOLD}║  Domain Breakdown:                                       ║${NC}"
  printf "${BOLD}║    %-53s ║${NC}\n" "Application Design & Build:    ${domain_score[design]}/${domain_total[design]}"
  printf "${BOLD}║    %-53s ║${NC}\n" "Application Deployment:        ${domain_score[deploy]}/${domain_total[deploy]}"
  printf "${BOLD}║    %-53s ║${NC}\n" "Observability & Maintenance:   ${domain_score[observe]}/${domain_total[observe]}"
  printf "${BOLD}║    %-53s ║${NC}\n" "Environment & Security:        ${domain_score[security]}/${domain_total[security]}"
  printf "${BOLD}║    %-53s ║${NC}\n" "Services & Networking:         ${domain_score[networking]}/${domain_total[networking]}"

  if [ -n "$flagged" ]; then
    echo -e "${BOLD}╠═══════════════════════════════════════════════════════════╣${NC}"
    printf "${BOLD}║  %-55s ║${NC}\n" "Flagged questions:${flagged}"
  fi

  echo -e "${BOLD}╠═══════════════════════════════════════════════════════════╣${NC}"
  if [ "$pct" -ge 80 ]; then
    echo -e "${BOLD}║  ${GREEN}RESULT: PASSED (${pct}%) — Excellent, you're ready!${NC}         ${BOLD}║${NC}"
  elif [ "$pct" -ge "$PASS_SCORE" ]; then
    echo -e "${BOLD}║  ${GREEN}RESULT: PASSED (${pct}%) — Good, but review weak areas${NC}     ${BOLD}║${NC}"
  else
    echo -e "${BOLD}║  ${RED}RESULT: FAILED (${pct}%) — Need more practice${NC}              ${BOLD}║${NC}"
  fi
  echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
}

# ─── EXAM START ─────────────────────────────────────────────────
trap cleanup EXIT

print_header
echo -e "  ${BOLD}Instructions:${NC}"
echo -e "  - You have 2 hours to complete 17 questions"
echo -e "  - Each question specifies a namespace — create it first"
echo -e "  - Use kubernetes.io/docs as your reference (as in the real exam)"
echo -e "  - After completing each task, press Enter to verify"
echo -e "  - Type 's' to skip, 'f' to flag, 'q' to end early"
echo ""
echo -e "  ${YELLOW}Press Enter to start the exam...${NC}"
read -r
start_time=$(date +%s)

# ─── Q1: Pod with Labels and Resources ─────────────────────────
print_header
echo -e "${BOLD}Q1 — Pod with Labels and Resources [4%] [Design & Build] Easy${NC}"
echo ""
echo "  Create namespace 'mock-q1'."
echo "  Create a pod named 'web' with image nginx:1.25 in namespace 'mock-q1'."
echo "  Add labels: app=web, tier=frontend"
echo "  Set resource requests: cpu=100m, memory=128Mi"
echo "  Set resource limits: cpu=250m, memory=256Mi"

result=$(wait_for_answer 1 4) || {
  if [ $? -eq 2 ]; then total_possible=70; show_results; exit 0; fi
  total_possible=$((total_possible + 4)); domain_total[design]=$((${domain_total[design]} + 4)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 1 4 design '
    phase=$(kubectl get pod web -n mock-q1 -o jsonpath="{.status.phase}" 2>/dev/null) &&
    [ "$phase" = "Running" ] &&
    img=$(kubectl get pod web -n mock-q1 -o jsonpath="{.spec.containers[0].image}") &&
    [ "$img" = "nginx:1.25" ] &&
    label=$(kubectl get pod web -n mock-q1 -o jsonpath="{.metadata.labels.app}") &&
    [ "$label" = "web" ] &&
    cpu=$(kubectl get pod web -n mock-q1 -o jsonpath="{.spec.containers[0].resources.requests.cpu}") &&
    [ "$cpu" = "100m" ]
  '
  pause
fi

# ─── Q2: Multi-Container Pod ───────────────────────────────────
print_header
echo -e "${BOLD}Q2 — Multi-Container Pod (Sidecar) [5%] [Design & Build] Medium${NC}"
echo ""
echo "  Create namespace 'mock-q2'."
echo "  Create a pod 'logger' with two containers:"
echo "    - 'app': image busybox, command: writes date to /var/log/app.log every 5s"
echo "    - 'sidecar': image busybox, command: tail -f /var/log/app.log"
echo "  Both containers share an emptyDir volume mounted at /var/log."

result=$(wait_for_answer 2 5) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 5)); domain_total[design]=$((${domain_total[design]} + 5)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 2 5 design '
    count=$(kubectl get pod logger -n mock-q2 -o jsonpath="{.spec.containers[*].name}" 2>/dev/null | wc -w) &&
    [ "$count" -eq 2 ] &&
    phase=$(kubectl get pod logger -n mock-q2 -o jsonpath="{.status.phase}") &&
    [ "$phase" = "Running" ]
  '
  pause
fi

# ─── Q3: CronJob ───────────────────────────────────────────────
print_header
echo -e "${BOLD}Q3 — CronJob [4%] [Design & Build] Medium${NC}"
echo ""
echo "  Create namespace 'mock-q3'."
echo "  Create a CronJob 'cleanup' that:"
echo "    - Runs every hour (0 * * * *)"
echo "    - Uses image busybox"
echo "    - Runs command: echo cleanup-done"
echo "    - Keeps 3 successful job histories and 1 failed"
echo "    - restartPolicy: OnFailure"

result=$(wait_for_answer 3 4) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 4)); domain_total[design]=$((${domain_total[design]} + 4)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 3 4 design '
    sched=$(kubectl get cronjob cleanup -n mock-q3 -o jsonpath="{.spec.schedule}" 2>/dev/null) &&
    [ "$sched" = "0 * * * *" ] &&
    hist=$(kubectl get cronjob cleanup -n mock-q3 -o jsonpath="{.spec.successfulJobsHistoryLimit}") &&
    [ "$hist" = "3" ]
  '
  pause
fi

# ─── Q4: Deployment + Rolling Update ───────────────────────────
print_header
echo -e "${BOLD}Q4 — Deployment + Rolling Update [4%] [Deployment] Medium${NC}"
echo ""
echo "  Create namespace 'mock-q4'."
echo "  Create Deployment 'webapp' with:"
echo "    - Image nginx:1.24, 3 replicas"
echo "    - RollingUpdate strategy: maxSurge=1, maxUnavailable=0"
echo "  Then update image to nginx:1.25."
echo "  Verify rollout completes successfully."

result=$(wait_for_answer 4 4) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 4)); domain_total[deploy]=$((${domain_total[deploy]} + 4)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 4 4 deploy '
    img=$(kubectl get deployment webapp -n mock-q4 -o jsonpath="{.spec.template.spec.containers[0].image}" 2>/dev/null) &&
    [ "$img" = "nginx:1.25" ] &&
    ready=$(kubectl get deployment webapp -n mock-q4 -o jsonpath="{.status.readyReplicas}") &&
    [ "$ready" = "3" ]
  '
  pause
fi

# ─── Q5: Helm Install + Upgrade ────────────────────────────────
print_header
echo -e "${BOLD}Q5 — Helm Install and Upgrade [3%] [Deployment] Easy${NC}"
echo ""
echo "  Create namespace 'mock-q5'."
echo "  Add the bitnami Helm repo (https://charts.bitnami.com/bitnami)."
echo "  Install nginx chart as release 'web' in namespace 'mock-q5'."
echo "  Upgrade the release to set replicaCount=2."

result=$(wait_for_answer 5 3) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 3)); domain_total[deploy]=$((${domain_total[deploy]} + 3)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 5 3 deploy '
    rev=$(helm list -n mock-q5 -o json 2>/dev/null | grep -c "web") &&
    [ "$rev" -ge 1 ]
  '
  pause
fi

# ─── Q6: Probes ────────────────────────────────────────────────
print_header
echo -e "${BOLD}Q6 — Liveness + Readiness + Startup Probes [4%] [Observability] Medium${NC}"
echo ""
echo "  Create namespace 'mock-q6'."
echo "  Create pod 'health-check' with image nginx and:"
echo "    - Liveness: httpGet on / port 80, period 10s"
echo "    - Readiness: tcpSocket on port 80, initialDelay 5s, period 5s"
echo "    - Startup: httpGet on / port 80, failureThreshold 30, period 10s"

result=$(wait_for_answer 6 4) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 4)); domain_total[observe]=$((${domain_total[observe]} + 4)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 6 4 observe '
    live=$(kubectl get pod health-check -n mock-q6 -o jsonpath="{.spec.containers[0].livenessProbe.httpGet.port}" 2>/dev/null) &&
    [ "$live" = "80" ] &&
    ready=$(kubectl get pod health-check -n mock-q6 -o jsonpath="{.spec.containers[0].readinessProbe.tcpSocket.port}") &&
    [ "$ready" = "80" ] &&
    startup=$(kubectl get pod health-check -n mock-q6 -o jsonpath="{.spec.containers[0].startupProbe.failureThreshold}") &&
    [ "$startup" = "30" ]
  '
  pause
fi

# ─── Q7: Troubleshooting ───────────────────────────────────────
print_header
echo -e "${BOLD}Q7 — Troubleshooting a Broken Pod [5%] [Observability] Medium${NC}"
echo ""
echo "  A broken pod has been created for you. Fix it."
echo ""
# Create the broken pod
kubectl create namespace mock-q7 --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl apply -f - <<'BROKEN_EOF' 2>/dev/null || true
apiVersion: v1
kind: Pod
metadata:
  name: broken-app
  namespace: mock-q7
spec:
  containers:
  - name: app
    image: nginx:9.99.99
    ports:
    - containerPort: 80
BROKEN_EOF
echo "  Pod 'broken-app' exists in namespace 'mock-q7' but is not running."
echo "  Diagnose and fix the pod so it runs successfully."
echo "  The intended image is nginx:1.25."

result=$(wait_for_answer 7 5) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 5)); domain_total[observe]=$((${domain_total[observe]} + 5)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 7 5 observe '
    img=$(kubectl get pod broken-app -n mock-q7 -o jsonpath="{.spec.containers[0].image}" 2>/dev/null) &&
    [ "$img" = "nginx:1.25" ] &&
    phase=$(kubectl get pod broken-app -n mock-q7 -o jsonpath="{.status.phase}") &&
    [ "$phase" = "Running" ]
  '
  pause
fi

# ─── Q8: ConfigMap + Secret ────────────────────────────────────
print_header
echo -e "${BOLD}Q8 — ConfigMap + Secret Injection [4%] [Environment & Security] Medium${NC}"
echo ""
echo "  Create namespace 'mock-q8'."
echo "  Create ConfigMap 'app-config' with DB_HOST=mysql and LOG_LEVEL=info."
echo "  Create Secret 'app-secret' with password=ckad2026."
echo "  Create pod 'config-pod' with image nginx that:"
echo "    - Loads ConfigMap as env vars (envFrom)"
echo "    - Mounts Secret at /etc/secret (read-only)"

result=$(wait_for_answer 8 4) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 4)); domain_total[security]=$((${domain_total[security]} + 4)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 8 4 security '
    env_val=$(kubectl exec config-pod -n mock-q8 -- env 2>/dev/null | grep -c "DB_HOST\|LOG_LEVEL") &&
    [ "$env_val" -ge 2 ] &&
    mount=$(kubectl get pod config-pod -n mock-q8 -o json 2>/dev/null | grep -c "/etc/secret") &&
    [ "$mount" -ge 1 ]
  '
  pause
fi

# ─── Q9: RBAC ──────────────────────────────────────────────────
print_header
echo -e "${BOLD}Q9 — RBAC: Role + RoleBinding [4%] [Environment & Security] Medium${NC}"
echo ""
echo "  Create namespace 'mock-q9'."
echo "  Create ServiceAccount 'dev-sa' in mock-q9."
echo "  Create Role 'pod-reader' allowing get, list, watch on pods."
echo "  Create RoleBinding 'dev-binding' binding pod-reader to dev-sa."
echo "  Verify dev-sa can list pods but cannot delete them."

result=$(wait_for_answer 9 4) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 4)); domain_total[security]=$((${domain_total[security]} + 4)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 9 4 security '
    can_list=$(kubectl auth can-i list pods --as=system:serviceaccount:mock-q9:dev-sa -n mock-q9 2>/dev/null) &&
    [ "$can_list" = "yes" ] &&
    can_del=$(kubectl auth can-i delete pods --as=system:serviceaccount:mock-q9:dev-sa -n mock-q9 2>/dev/null) &&
    [ "$can_del" = "no" ]
  '
  pause
fi

# ─── Q10: SecurityContext ───────────────────────────────────────
print_header
echo -e "${BOLD}Q10 — SecurityContext [4%] [Environment & Security] Medium${NC}"
echo ""
echo "  Create namespace 'mock-q10'."
echo "  Create pod 'secure-pod' with image nginx:alpine:"
echo "    - runAsUser: 1000, runAsGroup: 3000"
echo "    - Drop ALL capabilities"
echo "    - readOnlyRootFilesystem: true"
echo "    - allowPrivilegeEscalation: false"
echo "    - Mount emptyDir at /tmp so the container can write temp files"

result=$(wait_for_answer 10 4) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 4)); domain_total[security]=$((${domain_total[security]} + 4)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 10 4 security '
    user=$(kubectl get pod secure-pod -n mock-q10 -o jsonpath="{.spec.securityContext.runAsUser}" 2>/dev/null) &&
    [ "$user" = "1000" ] &&
    ro=$(kubectl get pod secure-pod -n mock-q10 -o jsonpath="{.spec.containers[0].securityContext.readOnlyRootFilesystem}") &&
    [ "$ro" = "true" ] &&
    npe=$(kubectl get pod secure-pod -n mock-q10 -o jsonpath="{.spec.containers[0].securityContext.allowPrivilegeEscalation}") &&
    [ "$npe" = "false" ]
  '
  pause
fi

# ─── Q11: NetworkPolicy ────────────────────────────────────────
print_header
echo -e "${BOLD}Q11 — NetworkPolicy [5%] [Networking] Hard${NC}"
echo ""
echo "  Create namespace 'mock-q11'."
echo "  Create pods: frontend (label role=frontend), api (label role=api), db (label role=db)"
echo "  Create NetworkPolicy 'api-netpol' that:"
echo "    - Targets pods with role=api"
echo "    - Allows ingress only from role=frontend on TCP 80"
echo "    - Allows egress only to role=db on TCP 5432"
echo "    - Allows DNS egress (UDP 53)"

result=$(wait_for_answer 11 5) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 5)); domain_total[networking]=$((${domain_total[networking]} + 5)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 11 5 networking '
    np=$(kubectl get networkpolicy api-netpol -n mock-q11 --no-headers 2>/dev/null) &&
    [ -n "$np" ] &&
    types=$(kubectl get networkpolicy api-netpol -n mock-q11 -o jsonpath="{.spec.policyTypes[*]}") &&
    echo "$types" | grep -q "Ingress" &&
    echo "$types" | grep -q "Egress"
  '
  pause
fi

# ─── Q12: Service + ClusterIP ──────────────────────────────────
print_header
echo -e "${BOLD}Q12 — Service (ClusterIP) [3%] [Networking] Easy${NC}"
echo ""
echo "  Create namespace 'mock-q12'."
echo "  Create Deployment 'api-server' with image nginx, 2 replicas, label app=api."
echo "  Create a ClusterIP Service 'api-svc' on port 80 targeting the deployment."

result=$(wait_for_answer 12 3) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 3)); domain_total[networking]=$((${domain_total[networking]} + 3)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 12 3 networking '
    ep=$(kubectl get endpoints api-svc -n mock-q12 -o jsonpath="{.subsets[0].addresses}" 2>/dev/null) &&
    [ -n "$ep" ]
  '
  pause
fi

# ─── Q13: Rollback ─────────────────────────────────────────────
print_header
echo -e "${BOLD}Q13 — Deployment Rollback [3%] [Deployment] Easy${NC}"
echo ""
echo "  Create namespace 'mock-q13'."
echo "  Create Deployment 'rollback-demo' with image nginx:1.24, 2 replicas."
echo "  Update image to nginx:1.25."
echo "  Then rollback to the previous revision."
echo "  Verify the image is nginx:1.24 after rollback."

result=$(wait_for_answer 13 3) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 3)); domain_total[deploy]=$((${domain_total[deploy]} + 3)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 13 3 deploy '
    img=$(kubectl get deployment rollback-demo -n mock-q13 -o jsonpath="{.spec.template.spec.containers[0].image}" 2>/dev/null) &&
    [ "$img" = "nginx:1.24" ] &&
    rev=$(kubectl rollout history deployment/rollback-demo -n mock-q13 2>/dev/null | grep -c "^[0-9]") &&
    [ "$rev" -ge 2 ]
  '
  pause
fi

# ─── Q14: PVC ──────────────────────────────────────────────────
print_header
echo -e "${BOLD}Q14 — PersistentVolumeClaim [4%] [Design & Build] Medium${NC}"
echo ""
echo "  Create namespace 'mock-q14'."
echo "  Create a PVC 'app-data' requesting 500Mi, access mode ReadWriteOnce."
echo "  Create pod 'data-writer' with image busybox (command: sleep 3600)"
echo "  that mounts the PVC at /app/data."

result=$(wait_for_answer 14 4) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 4)); domain_total[design]=$((${domain_total[design]} + 4)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 14 4 design '
    pvc=$(kubectl get pvc app-data -n mock-q14 --no-headers 2>/dev/null) &&
    [ -n "$pvc" ] &&
    mount=$(kubectl get pod data-writer -n mock-q14 -o jsonpath="{.spec.containers[0].volumeMounts[0].mountPath}" 2>/dev/null) &&
    [ "$mount" = "/app/data" ]
  '
  pause
fi

# ─── Q15: Ingress ──────────────────────────────────────────────
print_header
echo -e "${BOLD}Q15 — Ingress Resource [5%] [Networking] Medium${NC}"
echo ""
echo "  Create namespace 'mock-q15'."
echo "  Create two services: shop-svc and cart-svc (both on port 80, any backing pods)."
echo "  Create an Ingress 'app-ingress' that routes:"
echo "    - myapp.example.com/shop → shop-svc:80"
echo "    - myapp.example.com/cart → cart-svc:80"

result=$(wait_for_answer 15 5) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 5)); domain_total[networking]=$((${domain_total[networking]} + 5)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 15 5 networking '
    host=$(kubectl get ingress app-ingress -n mock-q15 -o jsonpath="{.spec.rules[0].host}" 2>/dev/null) &&
    [ "$host" = "myapp.example.com" ] &&
    path_count=$(kubectl get ingress app-ingress -n mock-q15 -o jsonpath="{.spec.rules[0].http.paths[*].path}" | wc -w) &&
    [ "$path_count" -ge 2 ]
  '
  pause
fi

# ─── Q16: Job with Deadline ────────────────────────────────────
print_header
echo -e "${BOLD}Q16 — Job with activeDeadlineSeconds [3%] [Design & Build] Easy${NC}"
echo ""
echo "  Create namespace 'mock-q16'."
echo "  Create a Job 'quick-task' with:"
echo "    - Image busybox, command: echo done"
echo "    - activeDeadlineSeconds: 60"
echo "    - backoffLimit: 3"

result=$(wait_for_answer 16 3) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 3)); domain_total[design]=$((${domain_total[design]} + 3)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 16 3 design '
    deadline=$(kubectl get job quick-task -n mock-q16 -o jsonpath="{.spec.activeDeadlineSeconds}" 2>/dev/null) &&
    [ "$deadline" = "60" ] &&
    backoff=$(kubectl get job quick-task -n mock-q16 -o jsonpath="{.spec.backoffLimit}") &&
    [ "$backoff" = "3" ]
  '
  pause
fi

# ─── Q17: ServiceAccount + Pod ──────────────────────────────────
print_header
echo -e "${BOLD}Q17 — ServiceAccount + Hardened Pod [6%] [Environment & Security] Hard${NC}"
echo ""
echo "  Create namespace 'mock-q17'."
echo "  Create ServiceAccount 'app-sa' in mock-q17."
echo "  Create pod 'hardened' with image nginx:alpine using 'app-sa':"
echo "    - runAsUser: 1000, runAsGroup: 3000"
echo "    - Drop ALL capabilities"
echo "    - readOnlyRootFilesystem: true"
echo "    - allowPrivilegeEscalation: false"
echo "    - Mount emptyDir at /tmp and /var/cache/nginx"
echo "  Verify the pod is Running."

result=$(wait_for_answer 17 6) || {
  if [ $? -eq 2 ]; then show_results; exit 0; fi
  total_possible=$((total_possible + 6)); domain_total[security]=$((${domain_total[security]} + 6)); pause
}
if [ $? -eq 0 ] 2>/dev/null; then
  verify_and_score 17 6 security '
    sa=$(kubectl get pod hardened -n mock-q17 -o jsonpath="{.spec.serviceAccountName}" 2>/dev/null) &&
    [ "$sa" = "app-sa" ] &&
    phase=$(kubectl get pod hardened -n mock-q17 -o jsonpath="{.status.phase}") &&
    [ "$phase" = "Running" ] &&
    user=$(kubectl get pod hardened -n mock-q17 -o jsonpath="{.spec.securityContext.runAsUser}") &&
    [ "$user" = "1000" ]
  '
  pause
fi

# ─── RESULTS ────────────────────────────────────────────────────
show_results
