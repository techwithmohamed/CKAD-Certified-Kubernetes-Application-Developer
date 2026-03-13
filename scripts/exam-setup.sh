#!/bin/bash
# CKAD Exam Setup — run this in the first 30 seconds
# Source: https://github.com/techwithmohamed/CKAD-Certified-Kubernetes-Application-Developer

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
k get nodes
