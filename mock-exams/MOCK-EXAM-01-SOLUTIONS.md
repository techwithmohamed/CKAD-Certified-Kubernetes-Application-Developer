# CKAD Mock Exam 01 — Solutions

**Kubernetes Version:** v1.35  
**Total Points:** 73%

---

## Question 1 — Pod with Resources and Labels [3%]

**Solution:**

```bash
kubectl run web-pod --image=nginx:1.25 \
  --labels=app=web \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=200m,memory=256Mi \
  -n default
```

Or via YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  labels:
    app: web
spec:
  containers:
  - name: web-pod
    image: nginx:1.25
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
```

**Verification:**
```bash
kubectl get pod web-pod -o yaml | grep -A 5 "resources\|labels"
# Should show:
# labels:
#   app: web
# resources:
#   limits:
#     cpu: 200m
#     memory: 256Mi
#   requests:
#     cpu: 100m
#     memory: 128Mi
```

---

## Question 2 — Multi-Container Pod [4%]

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-stack
  namespace: backend
spec:
  initContainers:
  - name: init-db
    image: busybox
    command: ["sh", "-c", "sleep 2"]
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
  containers:
  - name: app
    image: nginx:1.25
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
  - name: redis
    image: redis:7
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
```

**Deployment:**
```bash
kubectl apply -f app-stack.yaml
kubectl get pod app-stack -n backend
# Status should be Running after init container completes
```

---

## Question 3 — Pod with Init Container and SecurityContext [5%]

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
  namespace: dev
spec:
  securityContext:
    runAsUser: 1000
    fsGroup: 2000
  initContainers:
  - name: download
    image: busybox
    command: ["sh", "-c", "echo '#!/bin/sh' > /data/startup.sh && echo 'echo \"App started\"' >> /data/startup.sh && chmod +x /data/startup.sh"]
    volumeMounts:
    - name: data
      mountPath: /data
  containers:
  - name: runner
    image: alpine
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    emptyDir: {}
```

**Verification:**
```bash
kubectl apply -f init-pod.yaml -n dev
kubectl wait --for=condition=ready pod/init-pod -n dev --timeout=30s
kubectl exec init-pod -n dev -- ls -la /data/
# Output should show startup.sh with appropriate permissions
```

---

## Question 4 — Deployment with Rolling Update Strategy [4%]

**Solution:**

```bash
kubectl create deployment web-app \
  --image=nginx:1.25 \
  --replicas=3 \
  -n production \
  --dry-run=client -o yaml > deploy.yaml
```

Edit `deploy.yaml` to add:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
        version: v1
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
```

**Deployment:**
```bash
kubectl apply -f deploy.yaml
kubectl rollout status deployment/web-app -n production
```

---

## Question 5 — Deployment Rolling Update and Rollback [3%]

**Solution:**

```bash
# Create deployment
kubectl create deployment api --image=nginx:1.24 --replicas=2 -n apps

# Update image
kubectl set image deployment/api nginx=nginx:1.25 -n apps --record

# Wait for rollout
kubectl rollout status deployment/api -n apps

# Check history
kubectl rollout history deployment/api -n apps
# Output shows revision 1 and 2

# Rollback
kubectl rollout undo deployment/api -n apps

# Verify
kubectl rollout history deployment/api -n apps
kubectl get deployment api -n apps -o yaml | grep "image:"
# Should show nginx:1.24 again
```

---

## Question 6 — ConfigMap and Pod with Environment Variables [5%]

**Solution:**

```bash
# Create namespace (if doesn't exist)
kubectl create namespace config-test

# Create ConfigMap
kubectl create configmap app-config \
  --from-literal=DATABASE_HOST=postgres.default.svc.cluster.local \
  --from-literal=DATABASE_PORT=5432 \
  --from-literal=LOG_LEVEL=debug \
  -n config-test
```

Pod YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
  namespace: config-test
spec:
  containers:
  - name: app
    image: alpine
    command: ["sleep", "3600"]
    envFrom:
    - configMapRef:
        name: app-config
```

**Verification:**
```bash
kubectl apply -f config-pod.yaml
kubectl exec config-pod -n config-test -- env | grep DATABASE
# Output:
# DATABASE_HOST=postgres.default.svc.cluster.local
# DATABASE_PORT=5432
# LOG_LEVEL=debug
```

---

## Question 7 — Secret and Pod with Volume Mount [4%]

**Solution:**

```bash
# Create namespace
kubectl create namespace secrets-ns

# Create Secret
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=SuperSecret123 \
  -n secrets-ns
```

Pod YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
  namespace: secrets-ns
spec:
  containers:
  - name: app
    image: alpine
    command: ["sleep", "3600"]
    volumeMounts:
    - name: secret-vol
      mountPath: /etc/secrets
  volumes:
  - name: secret-vol
    secret:
      secretName: db-secret
```

**Verification:**
```bash
kubectl apply -f secret-pod.yaml
kubectl exec secret-pod -n secrets-ns -- ls -la /etc/secrets/
# Output shows: username, password files
kubectl exec secret-pod -n secrets-ns -- cat /etc/secrets/username
# Output: admin
```

---

## Question 8 — NetworkPolicy [5%]

**Solution:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-traffic
  namespace: network-test
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: database
    ports:
    - protocol: TCP
      port: 5432
  - to: []
    ports:
    - protocol: UDP
      port: 53
```

**Deployment:**
```bash
kubectl apply -f networkpolicy.yaml
kubectl get networkpolicy -n network-test
kubectl describe networkpolicy restrict-traffic -n network-test
```

**Key points:**
- All other ingress/egress traffic is implicitly denied
- DNS egress line allows queries to any destination (empty `to: []`)

---

## Question 9 — Service Exposure [4%]

**Solution:**

```bash
# Create Deployment
kubectl create deployment web-server \
  --image=nginx:1.25 \
  --replicas=2 \
  -n web

# Expose as Service
kubectl expose deployment web-server \
  --name=web-service \
  --port=80 \
  --target-port=80 \
  --type=ClusterIP \
  -n web

# Verify
kubectl get svc web-service -n web
kubectl get endpoints web-service -n web
# Should show 2 pod IPs in endpoints
```

---

## Question 10 — Ingress [5%]

**Solution:**

First create the Services (if they don't exist):

```bash
kubectl create namespace ingress-test
kubectl create deployment api-svc --image=nginx:1.25 -n ingress-test
kubectl expose deployment api-svc --port=8080 --target-port=80 -n ingress-test

kubectl create deployment web-svc --image=nginx:1.25 -n ingress-test
kubectl expose deployment web-svc --port=80 --target-port=80 -n ingress-test
```

Ingress YAML:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: ingress-test
spec:
  ingressClassName: nginx
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 8080
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
```

**Verification:**
```bash
kubectl apply -f ingress.yaml
kubectl get ingress -n ingress-test
kubectl describe ingress app-ingress -n ingress-test
```

---

## Question 11 — RBAC (Role + RoleBinding) [3%]

**Solution:**

```bash
# Create namespace
kubectl create namespace dev

# Create ServiceAccount
kubectl create serviceaccount developer -n dev

# Create Role
kubectl create role pod-reader \
  --verb=get,list,watch \
  --resource=pods \
  -n dev

# Create RoleBinding
kubectl create rolebinding developer-read-pods \
  --role=pod-reader \
  --serviceaccount=dev:developer \
  -n dev

# Verify permissions
kubectl auth can-i list pods -n dev --as=system:serviceaccount:dev:developer
# Output: yes

# Double-check what they CAN'T do
kubectl auth can-i delete pods -n dev --as=system:serviceaccount:dev:developer
# Output: no
```

---

## Question 12 — ClusterRole + ClusterRoleBinding [4%]

**Solution:**

```bash
# Create ClusterRole
kubectl create clusterrole deployment-manager \
  --verb=get,list,create,update,patch \
  --resource=deployments

# Create ClusterRoleBinding
kubectl create clusterrolebinding deploy-admin \
  --clusterrole=deployment-manager \
  --serviceaccount=default:admin

# Verify
kubectl get clusterrole deployment-manager
kubectl get clusterrolebinding deploy-admin
kubectl auth can-i update deployments --as=system:serviceaccount:default:admin
# Output: yes
```

---

## Question 13 — Pod with SecurityContext [5%]

**Solution:**

First create a ConfigMap (if needed):

```bash
kubectl create namespace secure
kubectl create configmap app-config --from-literal=key=value -n secure
```

Pod YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  namespace: secure
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: app
    image: alpine
    command: ["sleep", "3600"]
    securityContext:
      capabilities:
        drop:
        - ALL
      readOnlyRootFilesystem: true
    volumeMounts:
    - name: config-vol
      mountPath: /config
  volumes:
  - name: config-vol
    configMap:
      name: app-config
```

**Verification:**
```bash
kubectl apply -f secure-app.yaml
kubectl get pod secure-app -n secure -o yaml | grep -A 10 "securityContext"
```

---

## Question 14 — Pod with Liveness and Readiness Probes [4%]

**Solution:**

```bash
kubectl create namespace monitoring
```

Pod YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: health-check
  namespace: monitoring
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    livenessProbe:
      httpGet:
        path: /health
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 5
    readinessProbe:
      httpGet:
        path: /ready
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 3
```

**Verification:**
```bash
kubectl apply -f health-check.yaml
kubectl describe pod health-check -n monitoring | grep -A 3 "Liveness\|Readiness"
# Output shows probe configuration
```

**Note:** The probes will likely fail since nginx doesn't have `/health` or `/ready` endpoints by default, but the configuration is correct.

---

## Question 15 — StatefulSet with PVC and ConfigMap [5%]

**Solution:**

First create ConfigMap:

```bash
kubectl create namespace advanced
kubectl create configmap db-config \
  --from-literal=POSTGRES_DB=mydb \
  --from-literal=POSTGRES_USER=admin \
  -n advanced
```

StatefulSet YAML:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db-app
  namespace: advanced
spec:
  serviceName: db-service
  replicas: 3
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: postgres
        image: postgres:15
        envFrom:
        - configMapRef:
            name: db-config
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: fast
      resources:
        requests:
          storage: 1Gi
```

Also create a Headless Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-service
  namespace: advanced
spec:
  clusterIP: None
  selector:
    app: database
  ports:
  - port: 5432
    targetPort: 5432
```

**Verification:**
```bash
kubectl apply -f db-service.yaml
kubectl apply -f statefulset.yaml
kubectl get statefulset db-app -n advanced
kubectl get pvc -n advanced
# Should show data-db-app-0, data-db-app-1, data-db-app-2
```

---

## Scoring Summary

| Question | Domain | Weight | Difficulty | Time Est. |
|----------|--------|--------|-----------|-----------|
| 1 | Design & Build | 3% | Easy | 2-3 min |
| 2 | Design & Build | 4% | Medium | 4-5 min |
| 3 | Design & Build | 5% | Hard | 6-8 min |
| 4 | Deployment | 4% | Medium | 4-5 min |
| 5 | Deployment | 3% | Easy | 2-3 min |
| 6 | Configuration | 5% | Medium | 5-6 min |
| 7 | Configuration | 4% | Medium | 4-5 min |
| 8 | Networking | 5% | Hard | 6-8 min |
| 9 | Networking | 4% | Medium | 4-5 min |
| 10 | Networking | 5% | Hard | 6-8 min |
| 11 | RBAC | 3% | Easy | 2-3 min |
| 12 | RBAC | 4% | Medium | 4-5 min |
| 13 | Security | 5% | Hard | 6-8 min |
| 14 | Observability | 4% | Medium | 4-5 min |
| 15 | Design & Build | 5% | Hard | 6-8 min |

---

## Weak Area Review

If you scored below 50% in any domain, review:

- **Design & Build:** kubectl run, pod specs with resources, init containers, security contexts
- **Deployment:** kubectl create deployment, rolling updates, rollback strategies
- **Configuration:** ConfigMaps, Secrets, environment variable injection
- **Networking:** Services, Ingress, NetworkPolicy, DNS
- **RBAC:** ServiceAccounts, Roles, RoleBindings, ClusterRoles
- **Security:** SecurityContexts, capabilities, read-only filesystems
- **Observability:** Probes, logs, resource metrics

---

## Back to Mock Exam

[← Return to MOCK-EXAM-01](MOCK-EXAM-01.md)
