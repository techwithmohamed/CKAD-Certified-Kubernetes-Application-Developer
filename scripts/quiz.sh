#!/usr/bin/env bash
# CKAD Quick Quiz — Terminal-based random practice questions
# Usage: bash scripts/quiz.sh
# Requires: a running Kubernetes cluster (kind, minikube, or remote)

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

QUESTIONS=(
  "Create a pod named 'quiz-pod' with image nginx in namespace 'quiz'. Expose port 80.|kubectl create namespace quiz --dry-run=client -o yaml | kubectl apply -f - && kubectl run quiz-pod --image=nginx --port=80 -n quiz|kubectl get pod quiz-pod -n quiz -o jsonpath='{.status.phase}'"
  "Create a ConfigMap named 'quiz-config' with key 'MODE=exam' in namespace 'quiz'.|kubectl create configmap quiz-config --from-literal=MODE=exam -n quiz|kubectl get configmap quiz-config -n quiz -o jsonpath='{.data.MODE}'"
  "Create a Deployment named 'quiz-deploy' with image nginx:alpine, 3 replicas, in namespace 'quiz'.|kubectl create deployment quiz-deploy --image=nginx:alpine --replicas=3 -n quiz|kubectl get deployment quiz-deploy -n quiz -o jsonpath='{.spec.replicas}'"
  "Create a Secret named 'quiz-secret' with key 'password=ckad2026' in namespace 'quiz'.|kubectl create secret generic quiz-secret --from-literal=password=ckad2026 -n quiz|kubectl get secret quiz-secret -n quiz -o jsonpath='{.data.password}'"
  "Create a ServiceAccount named 'quiz-sa' in namespace 'quiz'.|kubectl create serviceaccount quiz-sa -n quiz|kubectl get serviceaccount quiz-sa -n quiz -o jsonpath='{.metadata.name}'"
  "Create a Job named 'quiz-job' using image busybox that runs 'echo CKAD' in namespace 'quiz'.|kubectl create job quiz-job --image=busybox -n quiz -- echo CKAD|kubectl get job quiz-job -n quiz -o jsonpath='{.metadata.name}'"
  "Create a CronJob named 'quiz-cron' with schedule '*/5 * * * *' using image busybox that runs 'date' in namespace 'quiz'.|kubectl create cronjob quiz-cron --image=busybox --schedule='*/5 * * * *' -n quiz -- date|kubectl get cronjob quiz-cron -n quiz -o jsonpath='{.spec.schedule}'"
  "Create a Role named 'quiz-role' in namespace 'quiz' that allows get,list on pods.|kubectl create role quiz-role --verb=get,list --resource=pods -n quiz|kubectl get role quiz-role -n quiz -o jsonpath='{.metadata.name}'"
  "Scale the deployment 'quiz-deploy' to 5 replicas in namespace 'quiz'.|kubectl scale deployment quiz-deploy --replicas=5 -n quiz|kubectl get deployment quiz-deploy -n quiz -o jsonpath='{.spec.replicas}'"
  "Set the image of deployment 'quiz-deploy' to nginx:latest in namespace 'quiz'.|kubectl set image deployment/quiz-deploy nginx-alpine=nginx:latest -n quiz || kubectl set image deployment/quiz-deploy nginx=nginx:latest -n quiz|kubectl get deployment quiz-deploy -n quiz -o jsonpath='{.spec.template.spec.containers[0].image}'"
)

score=0
total=0
TIME_PER_QUESTION=300  # 5 minutes per question

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

echo -e "${BOLD}╔═══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     CKAD Quick Quiz — Practice Mode   ║${NC}"
echo -e "${BOLD}║     ${TIME_PER_QUESTION}s per question, ${#QUESTIONS[@]} questions     ║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════╝${NC}"
echo ""

# Ensure quiz namespace exists
kubectl create namespace quiz --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Shuffle questions
shuffled=($(shuf -i 0-$((${#QUESTIONS[@]}-1)) -n ${#QUESTIONS[@]} 2>/dev/null || seq 0 $((${#QUESTIONS[@]}-1))))

for idx in "${shuffled[@]}"; do
  IFS='|' read -r question solution verify <<< "${QUESTIONS[$idx]}"
  total=$((total + 1))

  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}Question ${total}/${#QUESTIONS[@]}:${NC}"
  echo -e "${YELLOW}${question}${NC}"
  echo ""
  echo -e "You have ${TIME_PER_QUESTION} seconds. Press ${BOLD}Enter${NC} when done (or type ${BOLD}skip${NC}):"

  start_time=$(date +%s)
  read -r user_input

  if [ "$user_input" = "skip" ]; then
    echo -e "${RED}Skipped.${NC}"
    echo -e "  Solution: ${GREEN}${solution}${NC}"
    echo ""
    continue
  fi

  elapsed=$(( $(date +%s) - start_time ))
  if [ "$elapsed" -gt "$TIME_PER_QUESTION" ]; then
    echo -e "${RED}Time's up! (${elapsed}s)${NC}"
  else
    echo -e "  Completed in ${elapsed}s"
  fi

  # Verify
  if eval "$verify" &>/dev/null; then
    result=$(eval "$verify" 2>/dev/null)
    if [ -n "$result" ]; then
      echo -e "  ${GREEN}✓ CORRECT — Resource verified successfully${NC}"
      score=$((score + 1))
    else
      echo -e "  ${RED}✗ NOT FOUND — Resource not created correctly${NC}"
      echo -e "  Expected solution: ${GREEN}${solution}${NC}"
    fi
  else
    echo -e "  ${RED}✗ VERIFICATION FAILED${NC}"
    echo -e "  Expected solution: ${GREEN}${solution}${NC}"
  fi
  echo ""
done

show_score
