# Contributing

Thanks for wanting to improve this guide. Here's how to help.

## What's useful

- Fixing outdated information (Kubernetes version changes, exam format updates)
- Adding practice exercises that match the current CKAD curriculum
- Correcting YAML errors or broken commands
- Improving explanations that are unclear
- Adding missing topics from the [official CKAD curriculum](https://github.com/cncf/curriculum)
- Adding "Gotchas" sections to exercise READMEs (common mistakes for that topic)
- Improving verify.sh scripts with additional checks

## How to contribute

1. Fork this repo
2. Create a branch: `git checkout -b fix/your-change`
3. Make your changes
4. Test any YAML or commands in a real cluster before submitting
5. Run `make lint` to validate YAML
6. Open a pull request with a clear description of what you changed and why

## Adding a new exercise

Every exercise follows this structure:

```
exercises/
  NN-topic-name/
    README.md       # Task description, hints, verify commands, solution in <details>
    verify.sh       # Auto-verification script
    solution.yaml   # Reference YAML solution
```

### README.md template

```markdown
# Exercise NN — Topic Name `Difficulty`

> **Domain:** Domain Name (XX%) | **Target Time:** X min
> Related: [Section Link](../../README.md#section) | [YAML Skeleton](../../skeletons/relevant.yaml)

Brief description of what you'll practice.

## Task

1. Create namespace `exercise-NN`
2. Step-by-step instructions...

## Hints

- Helpful hint without giving the answer

## Gotchas

- Common mistake #1 for this topic
- Common mistake #2

## Verify

\`\`\`bash
kubectl get ... -n exercise-NN
\`\`\`

## Cleanup

\`\`\`bash
kubectl delete namespace exercise-NN
\`\`\`

<details>
<summary>Solution</summary>

\`\`\`yaml
# solution YAML
\`\`\`

</details>
```

### verify.sh template

```bash
#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="exercise-NN"
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

echo "Verifying Exercise NN — Topic Name"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Add your checks here using kubectl + jsonpath

echo ""
echo "Result: $PASS passed, $FAIL failed out of $((PASS + FAIL)) checks"
[ "$FAIL" -eq 0 ] && echo "🎉 Exercise NN PASSED!" || echo "❌ Exercise NN has failures — review and retry."
```

### Checklist before submitting

- [ ] `README.md` has Task, Hints, Gotchas, Verify, Cleanup, and Solution sections
- [ ] `verify.sh` tests all key requirements from the Task
- [ ] `solution.yaml` contains valid, tested YAML
- [ ] Tested in a real cluster (kind, minikube, or remote)
- [ ] Exercise maps to a specific CKAD domain
- [ ] Difficulty is labeled: Easy, Medium, or Hard
- [ ] Target completion time is specified

## "I Passed" wall

Did you pass the CKAD after studying with this repo? We'd love to hear about it!
Open a PR adding your name and score to the "I Passed" section, or share your experience in [GitHub Discussions](../../discussions).

## Guidelines

- Keep the tone casual and first-person where it fits — this reads like study notes, not a textbook
- All YAML must be valid and tested. If you add a new exercise, include a working solution
- Don't add content that isn't relevant to the CKAD exam
- Don't share actual exam questions — this violates the CNCF certification agreement
- Keep file structure clean. Exercises go in `exercises/`, skeletons go in `skeletons/`

## Reporting issues

If something is wrong or outdated, open an issue. Include:
- What's incorrect
- What the correct information is (with a source if possible)
- Which section of the README it's in

## Code of Conduct

Be respectful. We're all here to help people pass the CKAD.
