# CKAD Patterns — Quick Reference

Most exam tasks follow repeating patterns. Memorize these.

## Files in this directory

- **rbac-debug.md** — Permission denied? Fix ServiceAccount → Role → RoleBinding chain
- **cronjob-create.md** — Schedule tasks correctly (schedule format, image selection)
- **deployment-fix.md** — Pod stuck pending/crashloop? Apply debugging methodology
- **networkpolicy-allow-deny.md** — Allow traffic; block by default; fix selectors
- **ingress-debug.md** — Traffic not reaching pods? Path, host, backend mismatch
- **service-selector-mismatch.md** — Service endpoints empty? Label selector issues

## Speed Tips

- Always use `--dry-run=client -o yaml` to generate YAML
- Prefer `kubectl create` over editing files (faster)
- Label selectors MUST match exactly (case-sensitive, no spaces)
- RBAC: check SA exists BEFORE binding it
- NetworkPolicy 101: explicit allow; everything else denied by default

## Use Cases

Each pattern includes:
1. **Problem scenario** (realistic exam question)
2. **Symptoms** (what kubectl shows)
3. **Exact commands** (copy-paste ready)
4. **Minimal YAML** (if needed)
5. **Verification** (how to confirm it works)

Read each one before the exam. Practice each one 2× to muscle-memory level.
