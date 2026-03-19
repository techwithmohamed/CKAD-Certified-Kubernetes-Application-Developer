# Changelog

All notable changes to this repo are documented here. Follows [Keep a Changelog](https://keepachangelog.com/) format.

## [Unreleased]

### Added
- `solution.yaml` files for all 14 exercises — compare your attempt against the reference
- `scripts/mock-exam.sh` — full 17-question timed mock exam with auto-scoring and domain breakdown
- `scripts/create-cluster.sh` — one-command local cluster setup (kind, minikube, or k3d)
- `Makefile` — streamlined commands: `make setup`, `make quiz`, `make mock-exam`, `make verify-all`
- MkDocs configuration for GitHub Pages documentation site
- CI workflow to test exercises against a real kind cluster
- `CHANGELOG.md` (this file)
- Gotchas sections in exercise READMEs
- Enhanced `CONTRIBUTING.md` with exercise creation guide

### Changed
- Enhanced `scripts/quiz.sh` with domain filtering, speed mode, and score history
- Improved exercise READMEs with target completion times and gotchas

## [1.0.0] — 2026-03-19

### Added
- Initial release with 14 hands-on exercises covering all CKAD domains
- Exercises 01–10: Pod Basics, Multi-Container Pod, ConfigMap/Secret, RBAC, NetworkPolicy, Rolling Updates, Helm, Probes, Ingress/Gateway API, SecurityContext/PVC
- Exercises 11–14 (NEW): StatefulSet, DaemonSet, Init Containers, In-Place Scaling (v1.35 GA)
- 14 YAML skeleton templates in `skeletons/`
- `scripts/exam-setup.sh` — aliases, vim config, tab completion
- `scripts/quiz.sh` — interactive terminal quiz with auto-verification
- `verify.sh` scripts for all exercises
- Comprehensive README with full CKAD syllabus coverage (v1.35)
- Practice scenarios and 17-question mock exam in README
- GitHub Actions YAML validation workflow
- Issue templates for bug reports and exercise requests
- Kubernetes v1.35 curriculum and changes documentation
