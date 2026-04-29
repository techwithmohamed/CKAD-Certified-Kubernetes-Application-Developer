# Timed Exercises — Build Speed and Accuracy

These are exam-realistic tasks with time constraints. Use these the week before the real exam.

---

## 2-Minute Tasks (Warmup)

### Task 1: Create ServiceAccount + Verify
**Goal:** Create a ServiceAccount named 'worker' in namespace 'app' and retrieve its token.  
**Time:** 2 min

```bash
# Your commands here:

# Verify:
kubectl get sa worker -n app
kubectl get secret -n app $(kubectl get sa worker -n app -o jsonpath='{.secrets[0].name}') \
  -o jsonpath='{.data.token}' | base64 -d | wc -c
# Should output: token length
```

**Solution:**
```bash
kubectl create namespace app
kubectl create serviceaccount worker -n app
kubectl get sa worker -n app
```

---

### Task 2: Scale Deployment to 5 Replicas
**Goal:** Scale 'api-server' deployment to 5 replicas.  
**Time:** 1 min

```bash
kubectl scale deployment api-server --replicas=5
kubectl get deployment api-server
# Should show: READY 5/5
```

---

### Task 3: Create ConfigMap from Literal
**Goal:** Create ConfigMap named 'app-config' with key-value: database_url=postgres://db:5432  
**Time:** 1 min

```bash
kubectl create configmap app-config \
  --from-literal=database_url=postgres://db:5432
kubectl get configmap app-config -o yaml
```

---

## 5-Minute Tasks (Intermediate)

### Task 4: RBAC Debug — Fix Permission Denied
**Goal:** ServiceAccount 'reader' cannot `kubectl get pods`. Grant permission.  
**Time:** 5 min

```bash
# Given:
# - ServiceAccount 'reader' exists in 'default' namespace
# - It needs get,list permissions on pods
# Your task: Create Role + RoleBinding

# Solution:
kubectl create role pod-reader --verb=get,list --resource=pods
kubectl create rolebinding pod-reader-binding \
  --role=pod-reader \
  --serviceaccount=default:reader

# Verify:
kubectl auth can-i get pods --as=system:serviceaccount:default:reader
# Output: yes
```

---

### Task 5: Fix Service with Zero Endpoints
**Goal:** Service 'backend' shows 0 endpoints. Fix it.  
**Time:** 5 min

```bash
# Given:
# - Deployment 'api' with 2 replicas exists
# - Service 'backend' created but endpoints empty

# Debugging:
kubectl get svc backend -o jsonpath='{.spec.selector}'
# Output: {"app":"api-service"}

kubectl get pod --show-labels
# Output: app=api (mismatch!)

# Fix:
kubectl edit svc backend
# Change selector.app from "api-service" to "api"

# Verify:
kubectl get endpoints backend
# Should show 2 IPs
```

---

### Task 6: Create CronJob — Daily Database Backup
**Goal:** Create CronJob that runs at 1:00 AM daily, executes `pg_dump`.  
**Time:** 4 min

```bash
kubectl create cronjob db-backup \
  --image=ubuntu:22.04 \
  --schedule="0 1 * * *" \
  -- /bin/bash -c "pg_dump -U user -d mydb > /backup/dump_\$(date +%Y%m%d).sql"

# Verify:
kubectl get cronjob db-backup
kubectl describe cronjob db-backup
```

---

## 10-Minute Tasks (Advanced)

### Task 7: Multi-Step — Deploy App + Expose + Restrict Network
**Goal:** Complete flow:  
1. Create deployment 'webserver' (nginx, 3 replicas)  
2. Expose via service 'web-svc'  
3. Restrict traffic: only from 'frontend' pods  
**Time:** 10 min

```bash
# Step 1: Deploy
kubectl create deployment webserver --image=nginx --replicas=3

# Step 2: Expose
kubectl expose deployment webserver --port=80 --name=web-svc

# Step 3: NetworkPolicy
kubectl apply -f - <<'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-policy
spec:
  podSelector:
    matchLabels:
      app: nginx  # Match webserver pods
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              tier: frontend
      ports:
        - protocol: TCP
          port: 80
EOF

# Verify:
kubectl get deployment webserver
kubectl get svc web-svc
kubectl get networkpolicy web-policy
```

---

### Task 8: Debug Ingress — Traffic Not Reaching Backend
**Goal:** Ingress created but 503 Service Unavailable. Debug and fix.  
**Time:** 10 min

```bash
# Given:
# - Ingress 'web-ingress' created
# - Service 'web-svc' exists
# - Deployment 'web-app' has pods

# Step 1: Check ingress rules
kubectl get ingress web-ingress -o yaml

# Step 2: Check service endpoints
kubectl get endpoints web-svc
# If empty: service selector doesn't match pods

# Step 3: Check pod labels
kubectl get pod --show-labels

# Step 4: Verify service backend port
kubectl get svc web-svc -o yaml | grep -A 3 "ports:"

# Step 5: Verify ingress backend port matches service port (not targetPort!)
# Example fix:
kubectl edit ingress web-ingress
# Ensure backend.service.port.number matches service.spec.port (e.g., 80)

# Verify:
kubectl get endpoints web-svc  # Should not be empty
kubectl describe ingress web-ingress  # Should show valid rules
```

---

## Chaining: Speed Progression

Do tasks in this order:
1. **Monday:** All 2-min tasks (3× each for muscle memory)
2. **Tuesday:** All 5-min tasks (2× each, timed)
3. **Wednesday:** All 10-min tasks (1-2× each, with pressure)
4. **Thursday:** Mix tasks from each tier, time yourself
5. **Friday:** Take 1 full mock exam (2 hours, all scenario types)

---

## Scoring

- Completed in time = 10 points
- Completed 1 min over = 5 points
- Completed >2 min over = 0 points
- Syntax/logic errors = 0 points

Target: 80+ points per session

