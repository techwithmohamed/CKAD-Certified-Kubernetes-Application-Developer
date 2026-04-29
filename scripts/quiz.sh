#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# CKAD Quick Quiz — Terminal-based random practice questions
# ═══════════════════════════════════════════════════════════════
# Usage:
#   bash scripts/quiz.sh                  # all domains, normal mode
#   bash scripts/quiz.sh --domain design  # filter by domain
#   bash scripts/quiz.sh --speed          # 2-minute speed round
#   bash scripts/quiz.sh --domain security --speed
#
# Domains: design, deploy, observe, security, networking
# Requires: a running Kubernetes cluster (kind, minikube, or remote)
#
# Source: https://github.com/techwithmohamed/CKAD-Certified-Kubernetes-Application-Developer

set -euo pipefail
# Pasted one-liners may use the exam alias `k`; non-interactive shells do not expand aliases by default
shopt -s expand_aliases
alias k=kubectl

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

HISTORY_FILE="${HOME}/.ckad-quiz-history"
SPEED_MODE=false
DOMAIN_FILTER=""

# YAML helpers (heredocs cannot live inside the pipe-delimited QUESTIONS strings)
apply_quiz_networkpolicy() {
  kubectl apply -f - <<'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: quiz-netpol
  namespace: quiz
spec:
  podSelector:
    matchLabels:
      app: quiz-pod
  policyTypes:
  - Ingress
EOF
}

apply_quiz_pvc() {
  kubectl apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: quiz-pvc
  namespace: quiz
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
EOF
}

# Each QUESTION line is: domain|question|solution|verify
# Solutions often contain '|' (pipes), so we must NOT use IFS='|' read with only 4 fields.
# (Question must not include literal '|' characters. Verify is always the last segment after '|'.)
parse_quiz_line() {
  local line="$1"
  Q_PARSED_VERIFY="${line##*|}"
  local without_verify="${line%|*}"
  Q_PARSED_DOMAIN="${without_verify%%|*}"
  local rest="${without_verify#*|}"
  Q_PARSED_QUESTION="${rest%%|*}"
  Q_PARSED_SOLUTION="${rest#*|}"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --speed) SPEED_MODE=true; shift ;;
    --domain) DOMAIN_FILTER="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: bash scripts/quiz.sh [--domain DOMAIN] [--speed]"
      echo "Domains: design, deploy, observe, security, networking, all"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Format: "domain|question|solution|verify"
QUESTIONS=(
  "design|Create a pod named 'quiz-pod' with image nginx in namespace 'quiz'. Expose port 80.|kubectl create namespace quiz --dry-run=client -o yaml | kubectl apply -f - && kubectl run quiz-pod --image=nginx --port=80 -n quiz|kubectl get pod quiz-pod -n quiz -o jsonpath='{.status.phase}'"
  "security|Create a ConfigMap named 'quiz-config' with key 'MODE=exam' in namespace 'quiz'.|kubectl create configmap quiz-config --from-literal=MODE=exam -n quiz|kubectl get configmap quiz-config -n quiz -o jsonpath='{.data.MODE}'"
  "deploy|Create a Deployment named 'quiz-deploy' with image nginx:alpine, 3 replicas, in namespace 'quiz'.|kubectl create deployment quiz-deploy --image=nginx:alpine --replicas=3 -n quiz|kubectl get deployment quiz-deploy -n quiz -o jsonpath='{.spec.replicas}'"
  "security|Create a Secret named 'quiz-secret' with key 'password=ckad2026' in namespace 'quiz'.|kubectl create secret generic quiz-secret --from-literal=password=ckad2026 -n quiz|kubectl get secret quiz-secret -n quiz -o jsonpath='{.data.password}'"
  "security|Create a ServiceAccount named 'quiz-sa' in namespace 'quiz'.|kubectl create serviceaccount quiz-sa -n quiz|kubectl get serviceaccount quiz-sa -n quiz -o jsonpath='{.metadata.name}'"
  "design|Create a Job named 'quiz-job' using image busybox that runs 'echo CKAD' in namespace 'quiz'.|kubectl create job quiz-job --image=busybox -n quiz -- echo CKAD|kubectl get job quiz-job -n quiz -o jsonpath='{.metadata.name}'"
  "design|Create a CronJob named 'quiz-cron' with schedule '*/5 * * * *' using image busybox that runs 'date' in namespace 'quiz'.|kubectl create cronjob quiz-cron --image=busybox --schedule='*/5 * * * *' -n quiz -- date|kubectl get cronjob quiz-cron -n quiz -o jsonpath='{.spec.schedule}'"
  "security|Create a Role named 'quiz-role' in namespace 'quiz' that allows get,list on pods.|kubectl create role quiz-role --verb=get,list --resource=pods -n quiz|kubectl get role quiz-role -n quiz -o name"
  "deploy|Scale the deployment 'quiz-deploy' to 5 replicas in namespace 'quiz'.|kubectl scale deployment quiz-deploy --replicas=5 -n quiz|kubectl get deployment quiz-deploy -n quiz -o jsonpath='{.spec.replicas}'"
  "deploy|Set the image of deployment 'quiz-deploy' to nginx:latest in namespace 'quiz'.|kubectl set image deployment/quiz-deploy nginx=nginx:latest -n quiz|kubectl get deployment quiz-deploy -n quiz -o jsonpath='{.spec.template.spec.containers[0].image}'"
  "networking|Create a ClusterIP Service named 'quiz-svc' targeting quiz-deploy on port 80 in namespace 'quiz'.|kubectl expose deployment quiz-deploy --name=quiz-svc --port=80 -n quiz|kubectl get service quiz-svc -n quiz -o jsonpath='{.spec.type}'"
  "security|Create a RoleBinding 'quiz-binding' binding 'quiz-role' to ServiceAccount 'quiz-sa' in namespace 'quiz'.|kubectl create rolebinding quiz-binding --role=quiz-role --serviceaccount=quiz:quiz-sa -n quiz|kubectl get rolebinding quiz-binding -n quiz -o jsonpath='{.metadata.name}'"
  "observe|Get the logs of pod 'quiz-pod' in namespace 'quiz' (just run the command).|kubectl logs quiz-pod -n quiz|kubectl get pod quiz-pod -n quiz -o jsonpath='{.metadata.name}'"
  "networking|Create a NetworkPolicy 'quiz-netpol' in namespace 'quiz' that denies all ingress to pods labeled app=quiz-pod.|apply_quiz_networkpolicy|kubectl get networkpolicy quiz-netpol -n quiz -o jsonpath='{.metadata.name}'"
  "design|Create a PVC named 'quiz-pvc' requesting 100Mi with ReadWriteOnce in namespace 'quiz'.|apply_quiz_pvc|kubectl get pvc quiz-pvc -n quiz -o jsonpath='{.metadata.name}'"
)

score=0
total=0

if [ "$SPEED_MODE" = true ]; then
  TIME_PER_QUESTION=120  # 2 minutes in speed mode
else
  TIME_PER_QUESTION=300  # 5 minutes normal
fi

# Filter questions by domain if specified
FILTERED_QUESTIONS=()
for q in "${QUESTIONS[@]}"; do
  q_domain="${q%%|*}"
  if [ -z "$DOMAIN_FILTER" ] || [ "$DOMAIN_FILTER" = "all" ] || [ "$q_domain" = "$DOMAIN_FILTER" ]; then
    FILTERED_QUESTIONS+=("$q")
  fi
done

if [ ${#FILTERED_QUESTIONS[@]} -eq 0 ]; then
  echo -e "${RED}No questions found for domain '${DOMAIN_FILTER}'.${NC}"
  echo "Available domains: design, deploy, observe, security, networking"
  exit 1
fi

save_history() {
  local pct=$1
  local date_str
  date_str=$(date '+%Y-%m-%d %H:%M')
  local mode="normal"
  [ "$SPEED_MODE" = true ] && mode="speed"
  local domain="${DOMAIN_FILTER:-all}"
  echo "${date_str} | domain=${domain} | mode=${mode} | score=${score}/${total} (${pct}%)" >> "$HISTORY_FILE"
}

cleanup() {
  echo ""
  echo -e "${YELLOW}Cleaning up quiz resources...${NC}"
  kubectl delete namespace quiz --ignore-not-found --force --grace-period=0 2>/dev/null || true
  echo -e "${GREEN}Cleanup complete.${NC}"
}

show_score() {
  echo ""
  echo -e "${BOLD}═══════════════════════════════════════${NC}"
  echo -e "${BOLD}  FINAL SCORE: ${score}/${total}${NC}"
  if [ "$total" -gt 0 ]; then
    pct=$((score * 100 / total))
    save_history "$pct"
    if [ "$pct" -ge 80 ]; then
      echo -e "  ${GREEN}Excellent! You're exam-ready.${NC}"
    elif [ "$pct" -ge 66 ]; then
      echo -e "  ${YELLOW}Passing range. Keep practicing.${NC}"
    else
      echo -e "  ${RED}Below passing. Review weak areas.${NC}"
    fi
  fi
  echo -e "${BOLD}═══════════════════════════════════════${NC}"
}

trap cleanup EXIT

mode_label="Normal"
[ "$SPEED_MODE" = true ] && mode_label="Speed (${TIME_PER_QUESTION}s)"
domain_label="${DOMAIN_FILTER:-all}"

echo -e "${BOLD}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       CKAD Quick Quiz — Practice Mode         ║${NC}"
echo -e "${BOLD}║  ${#FILTERED_QUESTIONS[@]} questions | ${mode_label} | domain: ${domain_label}    ${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${DIM}This prompt only waits for Enter: it does not read commands from other terminals.${NC}"
echo -e "${DIM}• Use a second tab: run kubectl there, then return here and press ${BOLD}Enter${DIM} (empty line) to verify.${NC}"
echo -e "${DIM}• Or paste a single ${BOLD}kubectl ...${DIM} or ${BOLD}k ...${DIM} line at the prompt; it will be run here before verify.${NC}"
echo ""

# Show recent history if available
if [ -f "$HISTORY_FILE" ]; then
  recent=$(tail -3 "$HISTORY_FILE" 2>/dev/null || true)
  if [ -n "$recent" ]; then
    echo -e "${DIM}Recent scores:${NC}"
    echo "$recent" | while IFS= read -r line; do echo -e "  ${DIM}${line}${NC}"; done
    echo ""
  fi
fi

# Ensure quiz namespace exists (do not hide errors: verify needs a working 'quiz' namespace)
if ! kubectl get namespace quiz &>/dev/null; then
  if ! kubectl create namespace quiz; then
    echo -e "${RED}Cannot create namespace 'quiz' — is your cluster reachable and is kubectl configured?${NC}" >&2
    exit 1
  fi
fi

# Shuffle questions
shuffled=($(shuf -i 0-$((${#FILTERED_QUESTIONS[@]}-1)) -n ${#FILTERED_QUESTIONS[@]} 2>/dev/null || seq 0 $((${#FILTERED_QUESTIONS[@]}-1))))

for idx in "${shuffled[@]}"; do
  parse_quiz_line "${FILTERED_QUESTIONS[$idx]}"
  domain="$Q_PARSED_DOMAIN"
  question="$Q_PARSED_QUESTION"
  solution="$Q_PARSED_SOLUTION"
  verify="$Q_PARSED_VERIFY"
  total=$((total + 1))

  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}Question ${total}/${#FILTERED_QUESTIONS[@]}:${NC} ${DIM}[${domain}]${NC}"
  echo -e "${YELLOW}${question}${NC}"
  echo ""
  echo -e "You have ${TIME_PER_QUESTION} seconds. Press ${BOLD}Enter${NC} when done (or type ${BOLD}skip${NC}):"

  start_time=$(date +%s)
  read -r user_input
  # Strip Windows CRLF so pasted one-liners match kubectl/k patterns
  user_input="${user_input//$'\r'/}"

  if [ "$user_input" = "skip" ]; then
    echo -e "${RED}Skipped.${NC}"
    echo -e "  Solution: ${GREEN}${solution}${NC}"
    echo ""
    continue
  fi

  # A plain `read` does NOT run what you type: many users paste the expected kubectl line here.
  # If it looks like a one-line kubectl/k command, run it in this shell before we verify.
  if [[ -n "$user_input" ]]; then
    if [[ "$user_input" =~ ^[[:space:]]*kubectl[[:space:]] ]] || [[ "$user_input" =~ ^[[:space:]]*k[[:space:]]+ ]]; then
      echo -e "  ${DIM}Running: ${BOLD}${user_input}${NC}"
      set +e
      eval "$user_input"
      user_cmd_ec=$?
      set -e
      if [ "$user_cmd_ec" -ne 0 ]; then
        echo -e "  ${YELLOW}That command exited with status ${user_cmd_ec}.${NC}"
      fi
    else
      echo -e "  ${YELLOW}Not running the line you typed (not kubectl/k). Open another tab to run your commands, or paste a one-line kubectl or k command.${NC}"
    fi
  fi

  elapsed=$(( $(date +%s) - start_time ))
  if [ "$elapsed" -gt "$TIME_PER_QUESTION" ]; then
    echo -e "${RED}Time's up! (${elapsed}s)${NC}"
  else
    echo -e "  Completed in ${elapsed}s"
  fi

  # Verify: must succeed with exit 0. Under set -e, use explicit status capture.
  set +e
  verify_combined_out=$(eval "$verify" 2>&1)
  verify_status=$?
  set -e
  if [ "$verify_status" -eq 0 ]; then
    echo -e "  ${GREEN}✓ CORRECT — Resource verified successfully${NC}"
    score=$((score + 1))
  else
    echo -e "  ${RED}✗ VERIFICATION FAILED${NC}"
    if [ -n "$verify_combined_out" ]; then
      echo -e "  ${DIM}From kubectl:${NC}"
      while IFS= read -r _kl || [ -n "$_kl" ]; do
        echo -e "  ${DIM}  ${_kl}${NC}"
      done <<< "$verify_combined_out"
    fi
    echo -e "  Expected solution: ${GREEN}${solution}${NC}"
  fi
  echo ""
done

show_score
