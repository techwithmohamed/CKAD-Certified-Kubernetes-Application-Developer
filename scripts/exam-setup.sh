#!/bin/bash
# CKAD Exam Setup — run this in the first 30 seconds
# Source: https://github.com/techwithmohamed/CKAD-Certified-Kubernetes-Application-Developer

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Tip: run 'source scripts/exam-setup.sh' so aliases and exports persist in your shell."
fi

# Aliases
alias k=kubectl
export do='--dry-run=client -o yaml'
export now='--force --grace-period=0'

# Tab completion
source <(kubectl completion bash)
complete -F __start_kubectl k

# vim config for YAML
cat << 'EOF' >> ~/.vimrc
set expandtab
set tabstop=2
set shiftwidth=2
set number
EOF

# Verify
echo "--- Setup complete ---"
if kubectl get nodes >/dev/null 2>&1; then
  kubectl get nodes
else
  echo "kubectl is configured, but no reachable cluster context is currently set."
  echo "Create a cluster first (for example: bash scripts/create-cluster.sh)."
fi
