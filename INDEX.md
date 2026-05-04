# Complete Navigation Index

## Getting Started

- [START-HERE.md](START-HERE.md) — Pick your study timeline
- [STUDY-PATHS.md](STUDY-PATHS.md) — Daily schedules for each timeline
- [README.md](README.md) — Overview and repo structure

## Core Study Materials

### Patterns (6 most-tested topics)
- [patterns/rbac-debug.md](patterns/rbac-debug.md) — RBAC setup and debugging
- [patterns/deployment-fix.md](patterns/deployment-fix.md) — Fix broken deployments
- [patterns/service-selector-mismatch.md](patterns/service-selector-mismatch.md) — Service and endpoint issues
- [patterns/networkpolicy-allow-deny.md](patterns/networkpolicy-allow-deny.md) — NetworkPolicy rules
- [patterns/cronjob-create.md](patterns/cronjob-create.md) — CronJob and Job creation
- [patterns/ingress-debug.md](patterns/ingress-debug.md) — Ingress routing issues

### Hands-on Practice
- [exercises/](exercises/) — 14 exercises, speed drills, complex workflows
- [exercises/timed-exercises.md](exercises/timed-exercises.md) — Speed drills (2-5-10 min)
- [exercises/multi-step-scenarios.md](exercises/multi-step-scenarios.md) — Complex workflows
- [troubleshooting/broken/](troubleshooting/broken/) — YAML files with intentional errors

### Advanced Topics
- [troubleshooting/rbac/rbac-scenarios.md](troubleshooting/rbac/rbac-scenarios.md) — RBAC edge cases
- [troubleshooting/networking/networking-debug.md](troubleshooting/networking/networking-debug.md) — Network troubleshooting
- [troubleshooting/basics/COMMON-MISTAKES.md](troubleshooting/basics/COMMON-MISTAKES.md) — 20 common errors

## Reference Materials

- [KUBECTL-CHEATSHEET.md](KUBECTL-CHEATSHEET.md) — Commands ranked by frequency
- [EXAM-FEEDBACK-2026.md](EXAM-FEEDBACK-2026.md) — What actually appeared on 2026 exams (NDA-compliant feedback)
- [exam-strategy.md](exam-strategy.md) — Time management, exam day tips
- [skeletons/](skeletons/) — YAML templates for all resource types
- [scripts/](scripts/) — Setup scripts for exam environment

## Mock Exams

- [mock-exams/MOCK-EXAM-01.md](mock-exams/MOCK-EXAM-01.md) — Practice exam 1 (15 questions)
- [mock-exams/MOCK-EXAM-02.md](mock-exams/MOCK-EXAM-02.md) — Practice exam 2 (15 questions)

## Troubleshooting Guide

| Problem | Solution |
|---------|----------|
| Pod won't start (CrashLoopBackOff) | [patterns/deployment-fix.md](patterns/deployment-fix.md) |
| Service shows 0 endpoints | [patterns/service-selector-mismatch.md](patterns/service-selector-mismatch.md) |
| RBAC permission denied | [patterns/rbac-debug.md](patterns/rbac-debug.md) |
| Ingress returns 503/404 | [patterns/ingress-debug.md](patterns/ingress-debug.md) |
| Network traffic blocked | [troubleshooting/networking/networking-debug.md](troubleshooting/networking/networking-debug.md) |
| CronJob not triggering | [patterns/cronjob-create.md](patterns/cronjob-create.md) |
| Making silly mistakes | [troubleshooting/basics/COMMON-MISTAKES.md](troubleshooting/basics/COMMON-MISTAKES.md) |
| Need to review syntax | [KUBECTL-CHEATSHEET.md](KUBECTL-CHEATSHEET.md) |
| Confused about timing | [exam-strategy.md](exam-strategy.md) |

## Repo Structure

```
exercises/          Hands-on exercises, drills, scenarios
mock-exams/         Practice exams
patterns/           6 core patterns
troubleshooting/    Debugging, RBAC, networking, mistakes
scripts/            Setup scripts
skeletons/          YAML templates
```

## By Study Timeline

**1 Week:** START-HERE → STUDY-PATHS (1-week) → patterns → timed → MOCK-EXAM-01 → exam

**2 Weeks:** START-HERE → STUDY-PATHS (2-week) → patterns → exercises → MOCK-EXAM-01 → MOCK-EXAM-02 → exam

**3-4 Weeks:** START-HERE → STUDY-PATHS (3-4-week) → full path with all resources

**Test Level:** START-HERE → MOCK-EXAM-01 → review weak areas

## Quick Links

- **I'm new:** [START-HERE.md](START-HERE.md)
- **Daily schedule:** [STUDY-PATHS.md](STUDY-PATHS.md)
- **Practice now:** [mock-exams/MOCK-EXAM-01.md](mock-exams/MOCK-EXAM-01.md)
- **Commands:** [KUBECTL-CHEATSHEET.md](KUBECTL-CHEATSHEET.md)
- **Exam tips:** [exam-strategy.md](exam-strategy.md)
- **Mistakes to avoid:** [troubleshooting/basics/COMMON-MISTAKES.md](troubleshooting/basics/COMMON-MISTAKES.md)

## Files to Bookmark

- KUBECTL-CHEATSHEET.md
- exam-strategy.md
- basics/COMMON-MISTAKES.md
- patterns/rbac-debug.md
- patterns/deployment-fix.md
