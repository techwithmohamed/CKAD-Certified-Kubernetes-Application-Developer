# Multi-Step Scenarios — Real Exam Workflows

These scenarios are 10-15 minute tasks combining multiple concepts.  
In the real exam, you'll see questions like "Deploy an app, expose it, restrict access."

---

## Scenario 1: App Deployment with RBAC Restriction

**Time: 12 min**

1. Create Deployment `payment-api` (image: `python:3.9`, replicas: 2)
2. Create ServiceAccount `payment-app`
3. Grant it read-only access to ConfigMaps in namespace 'prod'
4. Expose deployment via Service (port 8080 → 5000)
5. Create a separate ServiceAccount 'auditor' that can list Secrets (but NOT Payments)
6. Verify both SAs have correct permissions

**Solution Sequence:**
```bash
# 1. Create namespace
kubectl create namespace prod

# 2. Deploy app
kubectl create deployment payment-api \
  --image=python:3.9 \
  --replicas=2 \
  -n prod

# 3. Create payment-app SA
kubectl create serviceaccount payment-app -n prod

# 4. Create role for payment-app (read ConfigMaps)
kubectl create role config-reader \
  --verb=get,list \
  --resource=configmaps \
  -n prod

kubectl create rolebinding payment-binding \
  --role=config-reader \
  --serviceaccount=prod:payment-app \
  -n prod

# 5. Expose service
kubectl expose deployment payment-api \
  --port=8080 \
  --target-port=5000 \
  --name=payment-svc \
  -n prod

# 6. Create auditor SA + role
kubectl create serviceaccount auditor -n prod

kubectl create role secret-reader \
  --verb=get,list \
  --resource=secrets \
  -n prod

kubectl create rolebinding auditor-binding \
  --role=secret-reader \
  --serviceaccount=prod:auditor \
  -n prod

# 7. Verify
kubectl auth can-i get configmaps \
  --as=system:serviceaccount:prod:payment-app -n prod
# yes

kubectl auth can-i list secrets \
  --as=system:serviceaccount:prod:auditor -n prod
# yes

kubectl auth can-i delete configmaps \
  --as=system:serviceaccount:prod:payment-app -n prod
# no (good)
```

---

## Scenario 2: Multi-Layer App with Network Segmentation

**Time: 14 min**

Deploy 3-tier app with network isolation:
1. Create namespace 'production'
2. Deploy `frontend` (nginx), `backend` (nginx), `database` (postgres)
3. Expose frontend to external traffic (port 80)
4. Restrict backend: only accepts traffic from frontend
5. Restrict database: only accepts traffic from backend
6. Create NetworkPolicy for each tier
7. Test connectivity

**Solution Sequence:**
```bash
# 1. Create namespace
kubectl create namespace production

# 2. Create deployments (simplified)
kubectl create deployment frontend --image=nginx -n production
kubectl create deployment backend --image=nginx -n production
kubectl create deployment database --image=postgres -n production

# 3. Label pods
kubectl set labels deployment/frontend tier=frontend -n production
kubectl set labels deployment/backend tier=backend -n production
kubectl set labels deployment/database tier=database -n production

# 4. Expose frontend to external (LoadBalancer)
kubectl expose deployment frontend \
  --port=80 \
  --type=LoadBalancer \
  --name=frontend-svc \
  -n production

# 5. Create internal services for backend, database
kubectl expose deployment backend \
  --port=3000 \
  --target-port=80 \
  --name=backend-svc \
  -n production

kubectl expose deployment database \
  --port=5432 \
  --name=database-svc \
  -n production

# 6. Create NetworkPolicies
# Frontend accepts external traffic
kubectl apply -f - <<'EOF' -n production
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector: {}  # From anywhere
      ports:
        - protocol: TCP
          port: 80
EOF

# Backend only from frontend
kubectl apply -f - <<'EOF' -n production
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              tier: frontend
      ports:
        - protocol: TCP
          port: 3000
EOF

# Database only from backend
kubectl apply -f - <<'EOF' -n production
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              tier: backend
      ports:
        - protocol: TCP
          port: 5432
EOF

# 7. Verify all resources exist
kubectl get deployment -n production
kubectl get svc -n production
kubectl get networkpolicy -n production
```

---

## Scenario 3: StatefulSet with Persistent Data + RBAC

**Time: 15 min**

1. Create StatefulSet `mysql-cluster` (mysql:5.7, replicas: 3)
2. Create PVC template (5Gi, ReadWriteOnce)
3. Create ServiceAccount 'db-admin'
4. Grant 'db-admin' full access to StatefulSets and PVCs
5. Create another ServiceAccount 'db-read' with read-only access
6. Verify permissions

**Solution Sequence:**
```bash
# 1. Create StatefulSet with PVC template
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-cluster
spec:
  serviceName: mysql-cluster
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 5Gi
EOF

# 2. Create headless service
kubectl expose statefulset mysql-cluster --port=3306 --clusterip=None

# 3. Create db-admin SA
kubectl create serviceaccount db-admin

# 4. Create role with full access to StatefulSets
kubectl create role db-admin-role \
  --verb=create,get,list,watch,update,patch,delete \
  --resource=statefulsets \
  -n default

# 5. Also add PVC access
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pvc-admin-role
rules:
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
EOF

# 6. Bind both roles to db-admin
kubectl create rolebinding db-admin-binding \
  --role=db-admin-role \
  --serviceaccount=default:db-admin

# 7. Create db-read SA
kubectl create serviceaccount db-read

# 8. Create read-only role
kubectl create role db-read-role \
  --verb=get,list,watch \
  --resource=statefulsets,persistentvolumeclaims \
  -n default

# 9. Bind to db-read
kubectl create rolebinding db-read-binding \
  --role=db-read-role \
  --serviceaccount=default:db-read

# 10. Verify
kubectl auth can-i delete statefulsets \
  --as=system:serviceaccount:default:db-admin
# yes

kubectl auth can-i delete statefulsets \
  --as=system:serviceaccount:default:db-read
# no
```

---

## Scenario 4: Troubleshooting Multi-Component Failure

**Time: 12 min**

You're given a broken 3-tier app:
- Frontend deployment showing 0 ready pods
- Backend service has 0 endpoints
- Database CronJob not running

Find and fix ALL 3 issues.

**Debugging Steps:**
```bash
# Issue 1: Frontend pods not ready
kubectl describe pod <frontend-pod>
# Likely: Image wrong, probes failing, or no resources

# Issue 2: Backend service 0 endpoints
kubectl get svc backend-svc
kubectl get endpoints backend-svc
# If empty: selector mismatch
kubectl get pod --show-labels
# Compare to: kubectl get svc backend-svc -o jsonpath='{.spec.selector}'

# Issue 3: CronJob not running
kubectl get cronjob db-backup
kubectl describe cronjob db-backup
# Check: schedule format, last schedule time
kubectl get job -l cronjob=db-backup
# If no jobs: schedule not valid or cluster not ready

# Fixes:
# 1. Fix frontend image/probe: kubectl set image deployment/frontend ...
# 2. Fix backend selector: kubectl edit svc backend-svc
# 3. Fix cronjob schedule: kubectl delete cronjob, recreate with correct schedule
```

---

## Practice Pattern

1. Set timer for 15 min
2. Read scenario carefully
3. Execute all steps
4. Verify each step with kubectl
5. Review: did you complete in time?

Do each scenario 2× this week.

