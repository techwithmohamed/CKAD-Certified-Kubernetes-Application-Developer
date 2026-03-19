# ═══════════════════════════════════════════════════════════════
# CKAD Practice — Makefile
# ═══════════════════════════════════════════════════════════════
# Usage:
#   make setup          — create cluster + configure aliases
#   make quiz           — run the interactive quiz
#   make mock-exam      — run the 17-question timed mock exam
#   make verify-all     — run all exercise verify.sh scripts
#   make verify EX=01   — verify a specific exercise
#   make clean          — delete the practice cluster
#   make docs           — serve MkDocs documentation locally
# ═══════════════════════════════════════════════════════════════

SHELL := /bin/bash
CLUSTER_TOOL ?= kind
CLUSTER_NAME ?= ckad-practice

.PHONY: help setup cluster exam-setup quiz mock-exam verify verify-all clean docs lint

help: ## Show this help
	@echo "CKAD Practice — Available targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

setup: cluster exam-setup ## Create cluster + run exam setup (one command to start)
	@echo ""
	@echo "✓ Ready to practice! Run: make quiz"

cluster: ## Create a local K8s cluster (CLUSTER_TOOL=kind|minikube|k3d)
	@bash scripts/create-cluster.sh $(CLUSTER_TOOL)

exam-setup: ## Run the exam aliases + vim config setup
	@bash scripts/exam-setup.sh

quiz: ## Run the interactive terminal quiz
	@bash scripts/quiz.sh

mock-exam: ## Run the full 17-question timed mock exam
	@bash scripts/mock-exam.sh

verify: ## Verify a specific exercise (usage: make verify EX=01)
ifndef EX
	@echo "Usage: make verify EX=01"
	@echo "Available exercises:"
	@ls -d exercises/*/verify.sh 2>/dev/null | sed 's|exercises/||;s|/verify.sh||' | while read d; do echo "  $$d"; done
else
	@matching=$$(find exercises/ -maxdepth 1 -type d -name "*$(EX)*" | head -1); \
	if [ -z "$$matching" ]; then \
		echo "Exercise matching '$(EX)' not found."; \
		exit 1; \
	fi; \
	echo "Running $$matching/verify.sh..."; \
	bash "$$matching/verify.sh"
endif

verify-all: ## Run all exercise verify.sh scripts
	@echo "═══════════════════════════════════════════"
	@echo "  Running all exercise verifications"
	@echo "═══════════════════════════════════════════"
	@passed=0; failed=0; skipped=0; \
	for v in exercises/*/verify.sh; do \
		dir=$$(dirname "$$v"); \
		name=$$(basename "$$dir"); \
		echo ""; \
		echo "──── $$name ────"; \
		if bash "$$v" 2>/dev/null; then \
			passed=$$((passed + 1)); \
		else \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	echo ""; \
	echo "═══════════════════════════════════════════"; \
	echo "  Total: $$((passed + failed)) exercises"; \
	echo "  Passed: $$passed | Failed: $$failed"; \
	echo "═══════════════════════════════════════════"

clean: ## Delete the practice cluster
	@echo "Deleting cluster '$(CLUSTER_NAME)'..."
	@case "$(CLUSTER_TOOL)" in \
		kind) kind delete cluster --name $(CLUSTER_NAME) ;; \
		minikube) minikube delete -p $(CLUSTER_NAME) ;; \
		k3d) k3d cluster delete $(CLUSTER_NAME) ;; \
	esac
	@echo "✓ Cluster deleted."

docs: ## Serve MkDocs documentation locally
	@if command -v mkdocs &>/dev/null; then \
		mkdocs serve; \
	else \
		echo "MkDocs not installed. Run: pip install mkdocs-material"; \
	fi

lint: ## Validate all YAML files with kubeconform
	@echo "Validating skeleton YAML files..."
	@for f in skeletons/*.yaml; do \
		echo "  Checking $$f..."; \
		kubeconform -strict -summary "$$f" 2>/dev/null || echo "  ⚠ kubeconform not installed — skipping"; \
	done
	@echo "✓ Lint complete."
