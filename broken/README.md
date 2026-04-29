# Broken Scenarios — Real Exam Debugging

All YAML files in this directory have intentional errors. Your job is to:

1. **Identify** the error
2. **Fix** it  
3. **Verify** it works

Each file includes a README with:
- Problem description
- Symptoms observable via kubectl
- Expected fix

---

## Files

- **broken-pod.yaml** — Image doesn't exist, command wrong, or missing volume
- **broken-probes.yaml** — Liveness/Readiness failing (wrong port, path, timeout)
- **broken-rbac.yaml** — ServiceAccount, Role, or RoleBinding misconfigured
- **broken-service.yaml** — Service exists but no endpoints (selector mismatch)
- **broken-networkpolicy.yaml** — Traffic blocked when it shouldn't be
- **broken-ingress.yaml** — Path/host/backend misconfigured
- **broken-cronjob.yaml** — Schedule wrong, command fails, restartPolicy missing
- **broken-deployment.yaml** — Pod crash, replica mismatch, rolling update stuck

---

## How to Use

### 1. Try It
```bash
kubectl apply -f broken-pod.yaml
kubectl get pod
kubectl describe pod <name>
kubectl logs <name>
# What's broken?
```

### 2. Fix It
```bash
# Edit the YAML file
# OR fix via kubectl commands
kubectl edit pod <name>
# OR recreate
kubectl delete -f broken-pod.yaml
# ... fix YAML ...
kubectl apply -f broken-pod.yaml
```

### 3. Verify
```bash
kubectl get pod
# Should See: STATUS Running, READY 1/1
kubectl logs <name>
# Should show: no errors
```

---

## Exam Strategy

In the real exam, you'll see broken resources. Use this methodology:

1. **Read the scenario** — "Pod stuck in CrashLoopBackOff"
2. **kubectl describe** — Get clues (image, probes, events)
3. **kubectl logs** — See actual error message
4. **kubectl get -o yaml** — Compare with working examples from patterns/
5. **Fix** — Edit YAML or use `kubectl set` commands
6. **Verify** — `kubectl get` shows correct state
7. **Move on** — Don't overthink; spend max 5 min per task

---

## Most Common Exam Breaks

- ❌ Liveness probe too aggressive (app takes time to start)
- ❌ Image tag wrong or doesn't exist
- ❌ Service selector doesn't match pod labels
- ❌ Missing secret/configmap volume mount
- ❌ Port number in service differs from container
- ❌ RBAC: ServiceAccount not bound to Role
- ❌ NetworkPolicy: selector grammar wrong
- ❌ CronJob schedule typo

