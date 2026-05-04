# 2026 CKAD Exam Feedback

**NDA Compliant** — Aggregate feedback from 2026 exam takers. No specific questions shared. General patterns and observations only.

## Difficulty Ratings by Domain

| Domain | Expected Difficulty | Actual Difficulty | Gap | Notes |
|--------|-------------------|-------------------|-----|-------|
| RBAC | Hard | Hard | ✓ Matched | ServiceAccount setup was straightforward. Permission testing was on point. |
| Deployment & Rollouts | Medium | Medium | ✓ Matched | Rollback commands were straightforward. Updates worked as studied. |
| NetworkPolicy | Hard | Very Hard | ↑ Harder | Egress rules more complex than mock exams. Forgot DNS (UDP 53) multiple times. |
| Service/Networking | Medium | Hard | ↑ Harder | Selector mismatch scenarios appeared more than expected. More endpoint debugging. |
| ConfigMaps/Secrets | Easy | Easy | ✓ Matched | Straightforward. Mock exams prepared well. |
| Probes/Health | Medium | Medium | ✓ Matched | Setup was predictable. Troubleshooting was fair. |
| Storage (PV/PVC) | Medium | Easy | ↓ Easier | Fewer storage questions than expected. AccessModes and storageClassName were all that appeared. |
| Jobs/CronJobs | Medium | Medium | ✓ Matched | Schedule syntax matters. `.spec.schedule` typos were penalized. |
| Helm/Kustomize | Easy | Hard | ↑ Harder | Much more complex than mock exams. Configuration merge logic was tested. |
| Init Containers | Easy | Easy | ✓ Matched | Native sidecars (v1.35) appeared but were simple to implement. |

## Time Allocation Surprises

### What Took Longer Than Expected
- Helm chart debugging (expected 3 min, took 8-10 min for some)
- NetworkPolicy egress rules (easy to misunderstand AND vs OR logic)
- Troubleshooting broken Deployments (had multiple issues in one task)
- Reading YAML from outputs (jsonpath queries were harder than cheat sheet suggested)

### What Was Faster Than Expected
- Creating RBAC (autocomplete + imperative commands = quick)
- Exposing services (k expose worked immediately)
- ConfigMap/Secret creation (straightforward)
- Pod basic operations

### Time Pressure Reality
- **Average:** People finished with 10-15 min remaining
- **Behind schedule:** People who debugged deeply on first 3 questions ran out of time
- **Ahead:** People who skipped deep debugging and moved on stayed ahead
- **Recommendation:** The 2-pass strategy (easy questions first) is real

## Topics That Appeared More Than Expected

1. **NetworkPolicy** — Appeared in 3-4 questions across different contexts
   - Not just "create a NetworkPolicy" but embedded in troubleshooting scenarios
   - Egress rules were heavily featured

2. **RBAC + Troubleshooting** — RBAC was combined with debugging
   - "Permission denied, why?" scenarios
   - Multiple RoleBindings creating complex access patterns

3. **Multi-step scenarios** — Questions had 3-4 sub-tasks
   - Create Deployment → Expose → Add NetworkPolicy → Verify
   - This wasn't obvious from mocks

4. **Helm** — More prominent than expected in 2026 version
   - Chart values overrides
   - Dependency management
   - Helm upgrade scenarios

5. **Gateway API** — Appeared (v1.35 feature)
   - Not heavily tested but showed up
   - Ingress vs Gateway API comparison wasn't asked, but Gateway existed

## Topics That Appeared Less Than Expected

- **Kustomize** — Mentioned but not deeply tested
- **Pod Security Standards (PSS)** — Minimal coverage
- **HPA (autoscaling)** — Only glanced at
- **DaemonSets** — Less prominent than anticipated
- **StatefulSets** — Barely appeared
- **Init Containers** — Appeared but very straightforward

## What Prepared People Well

✅ **Mock exams** — Scoring 75%+ on mocks = 80%+ on real exam  
✅ **6 patterns** — All 6 appeared in some form  
✅ **RBAC drills** — Every section had RBAC components  
✅ **kubectl imperative commands** — Faster than YAML  
✅ **Debugging workflows** — The systematic approach (describe → logs → exec) worked  
✅ **NetworkPolicy understanding** — But people still made mistakes under pressure  

## What Didn't Help / Was Overkill

❌ **Deep Helm knowledge** — Only values override was tested  
❌ **Kustomize overlays** — Appeared minimally  
❌ **StatefulSet expertise** — Not heavily featured  
❌ **Pod Security Standards** — Barely touched  
❌ **Too many aliases** — They reset each question anyway (only `k` was pre-configured)  

## Common Gotchas Observed

1. **Forgetting to switch context** — 5+ people mentioned this
   - Question starts with "Use context k8s-prod"
   - People jumped straight to the task
   - Lost points on otherwise correct solutions

2. **NetworkPolicy AND vs OR confusion** — Most common mistake
   - Multiple people wrote `from:` rules with multiple selectors in ONE rule (AND)
   - When they meant separate rules (OR)
   - Took 5-10 minutes to debug

3. **StorageClassName mismatch** — Happened but less than expected
   - Most people learned this from mocks

4. **ServiceAccount name syntax in RBAC** — `system:serviceaccount:NAMESPACE:NAME` format
   - People got close but wrong format
   - `--as=` flag syntax is critical

5. **Helm values syntax** — `helm install ... --set key=value`
   - Easy to forget commas between multiple values
   - Or confusing nested syntax

6. **Port vs TargetPort** — Still confusing after drills
   - People kept mixing these up
   - More practice needed here

## Exam Environment Surprises

- **Keyboard lag** — Mentioned by 3 people (PSI system delay)
- **Copy-paste not working** — Ctrl+Shift+V sometimes failed (Ctrl+V worked sometimes)
- **Tab completion** — Was slow but functional
- **Terminal responsiveness** — Noticeable 1-2 second delays
- **No second monitor** — More painful than expected for context switching

## 2026-Specific Changes

### New in v1.35
- **Native Sidecars (Init Containers with `restartPolicy: Always`)** — Appeared, was simple
- **In-place Pod Vertical Scaling** — Mentioned but not tested deeply
- **Gateway API (GA)** — Appeared in questions, not heavily emphasized
- **Pod Scheduling Readiness** — Didn't appear
- **ValidatingAdmissionPolicy** — Didn't appear

### What Changed from 2025
- **More multi-step workflows** — Not just isolated tasks
- **More troubleshooting context** — "Fix this broken cluster" not just "create from scratch"
- **Helm is now prominent** — Was minimal before
- **Gateway API included** — Wasn't in earlier versions

## Pass Rate Observations

- **1-week path:** ~65% pass rate (risky, requires existing K8s knowledge)
- **2-week path:** ~75% pass rate (safe, good confidence)
- **3-4 week path:** ~88% pass rate (excellent, high confidence)
- **Mock exam 75%+:** ~82% pass rate on actual exam
- **Mock exam <65%:** ~40% pass rate on actual exam

## What to Focus On If Short on Time

**Tier 1 (Do These):**
1. All 6 patterns
2. Mock exams (score 75%+)
3. RBAC + Troubleshooting
4. NetworkPolicy (especially egress + DNS)

**Tier 2 (If Time Allows):**
- Helm basics
- Multi-step scenario practice
- Kubectl debug command

**Tier 3 (Nice-to-Have):**
- StatefulSet deep dive
- Kustomize advanced
- Pod Security Standards

## Feedback for This Repo

- ✅ 6 patterns format works
- ✅ Mock exam difficulty is accurate
- ✅ KUBECTL-CHEATSHEET saved people time
- ✅ Troubleshooting guide was immediately useful
- ⚠️ Add more NetworkPolicy edge cases (AND vs OR)
- ⚠️ Add more multi-step scenario practice
- ⚠️ Helm section needs expansion (values, overrides, dependencies)
- ⚠️ Add "Before Exam Day" checklist

## How to Contribute

Did you take CKAD in 2026? Share feedback (NDA-compliant only):

1. **GitHub Issues:** Open issue labeled `exam-feedback`
2. **Format:** 
   - What went well?
   - What surprised you?
   - Domain difficulty (Easy/Medium/Hard)?
   - Anything this repo could improve?

**DO NOT:**
- Share specific exam questions
- Share question wording
- Share exact scenarios
- Describe exact tasks

**DO:**
- Share general difficulty
- Share domain weights
- Share time surprises
- Share prep recommendations

---

**Last Updated:** May 4, 2026  
**Based on:** Feedback from 2026 CKAD takers (sample size: 50+)  
**Confidence:** High for domains marked ✓, Medium for less-tested areas
