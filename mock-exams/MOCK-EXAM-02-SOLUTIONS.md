# CKAD Mock Exam 02 — Solutions

**Kubernetes Version:** v1.35  
**Total Points:** 80%

---

## Question 1 — Pod with Environment Variables [3%]

**Solution:**

```bash
kubectl run app-pod \
  --image=alpine:3.18 \
  --env=APP_NAME=MyApp \
  --env=ENVIRONMENT=production \
  --env=DEBUG=false \
  -n default
```

Or via YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app-pod
    image: alpine:3.18
    env:
    - name: APP_NAME
      value: MyApp
    - name: ENVIRONMENT
      value: production
    - name: DEBUG
      value: "false"
```

**Verification:**
```bash
kubectl exec app-pod -- env | grep APP_NAME
# Output: APP_NAME=MyApp
kubectl exec app-pod -- env | grep ENVIRONMENT
# Output: ENVIRONMENT=production
```

---

## Question 2 — Pod with Shared Volume (Sidecar Pattern) [4%]

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-sidecar
  namespace: dev
spec:
  containers:
  - name: app
    image: nginx:1.25
    volumeMounts:
    - name: shared
      mountPath: /data
  - name: log-collector
    image: busybox
    command: ["tail", "-f", "/data/access.log"]
    volumeMounts:
    - name: shared
      mountPath: /data
  volumes:
  - name: shared
    emptyDir: {}
```

**Verification:**
```bash
kubectl apply -f app-sidecar.yaml -n dev
kubectl logs app-sidecar -c log-collector -n dev
# Should show the tail output (or wait message initially)
```

---

## Question 3 — Pod with Init Container and PVC [5%]

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: worker-job
  namespace: staging
spec:
  restartPolicy: OnFailure
  initContainers:
  - name: downloader
    image: alpine
    command: ["sh", "-c", "apk add --no-cache curl && curl -o /data/input.zip https://example.com/data.zip"]
    volumeMounts:
    - name: work
      mountPath: /data
  containers:
  - name: processor
    image: alpine
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: work
      mountPath: /data
  volumes:
  - name: work
    persistentVolumeClaim:
      claimName: work-pvc
```

**Deployment:**
```bash
kubectl apply -f worker-job.yaml -n staging
```

---

## Question 4 — Deployment with Probes [4%]

**Solution:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        version: v2.0
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 10
```

**Deployment:**
```bash
kubectl apply -f frontend-deploy.yaml
kubectl rollout status deployment/frontend -n web
```

---

## Question 5 — Deployment with Rolling Update Strategy [3%]

**Solution:**

```bash
kubectl create deployment backend \
  --image=node:18-alpine \
  --replicas=2 \
  -n production \
  --dry-run=client -o yaml > backend.yaml
```

Edit to add strategy:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: production
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: node
        image: node:18-alpine
```

**Deployment:**
```bash
kubectl apply -f backend.yaml
```

---

## Question 6 — ConfigMap, Secret, Pod with Mixed Mounts [5%]

**Solution:**

```bash
# Step 1: Create sample config file
cat > config.txt <<EOF
database_host=postgres.default.svc.cluster.local
database_port=5432
log_level=info
EOF

# Step 2: Create ConfigMap from file
kubectl create configmap app-settings --from-file=config.txt -n config

# Step 3: Create Secret
kubectl create secret generic api-keys \
  --from-literal=API_KEY=sk-secret123 \
  --from-literal=API_SECRET=secret-value \
  -n config
```

Pod YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-consumer
  namespace: config
spec:
  containers:
  - name: app
    image: alpine
    command: ["sleep", "3600"]
    envFrom:
    - secretRef:
        name: api-keys
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-settings
```

**Verification:**
```bash
kubectl apply -f config-consumer.yaml
kubectl exec config-consumer -n config -- env | grep API_KEY
# Output: API_KEY=sk-secret123
kubectl exec config-consumer -n config -- cat /etc/config/config.txt
# Output: database_host=postgres.default.svc.cluster.local...
```

---

## Question 7 — StatefulSet with ConfigMap and Secret [4%]

**Solution:**

```bash
kubectl create namespace database

# Create ConfigMap
kubectl create configmap postgres-config \
  --from-literal=POSTGRES_DB=appdb \
  --from-literal=POSTGRES_USER=dbadmin \
  -n database

# Create Secret
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_PASSWORD=SecurePass123 \
  -n database
```

StatefulSet YAML:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: database
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: database
spec:
  serviceName: postgres-service
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        envFrom:
        - configMapRef:
            name: postgres-config
        - secretRef:
            name: postgres-secret
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 5Gi
```

**Verification:**
```bash
kubectl apply -f postgres-service.yaml
kubectl apply -f postgres-statefulset.yaml
kubectl get statefulset postgres -n database
kubectl get pods postgres-* -n database
```

---

## Question 8 — NetworkPolicy with Multiple Sources [5%]

**Solution:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: isolate-backend
  namespace: mesh
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    - podSelector:
        matchLabels:
          app: admin
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  - to: []
    ports:
    - protocol: UDP
      port: 53
```

**Key points:**
- Multiple `from` entries are OR'd together
- DNS egress allows any destination (`to: []`)

**Deployment:**
```bash
kubectl apply -f isolate-backend.yaml
```

---

## Question 9 — NodePort Service [4%]

**Solution:**

```bash
# Create Deployment
kubectl create deployment api-server \
  --image=nginx:1.25 \
  --replicas=2 \
  -n api

# Create Service
kubectl create service nodeport api-nodeport \
  --tcp=8080:80 \
  --node-port=30001 \
  -n api

# Alternative: expose then edit
kubectl expose deployment api-server \
  --port=8080 \
  --target-port=80 \
  --type=NodePort \
  --name=api-nodeport \
  -n api \
  --dry-run=client -o yaml | sed 's/nodePort:.*/nodePort: 30001/' | kubectl apply -f -
```

**Verification:**
```bash
kubectl get svc api-nodeport -n api
# output shows port 8080:30001/TCP
kubectl describe svc api-nodeport -n api
```

---

## Question 10 — Gateway API HTTPRoute [5%]

**Solution:**

Assumes Gateway `main-gateway` exists. If not, create it first:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: routing
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
```

HTTPRoute YAML:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-route
  namespace: routing
spec:
  parentRefs:
  - name: main-gateway
    namespace: routing
  hostnames:
  - myapp.internal
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api/v1
    backendRefs:
    - name: api-backend
      port: 8080
  - matches:
    - path:
        type: PathPrefix
        value: /static
    backendRefs:
    - name: static-server
      port: 80
```

**Verification:**
```bash
kubectl apply -f gateway.yaml
kubectl apply -f httproute.yaml
kubectl get httproute -n routing
```

---

## Question 11 — ClusterRole and ClusterRoleBinding [3%]

**Solution:**

```bash
# Create namespace and ServiceAccount
kubectl create namespace apps
kubectl create serviceaccount app-reader -n apps

# Create ClusterRole
kubectl create clusterrole pod-lister \
  --verb=list \
  --resource=pods

# Create ClusterRoleBinding
kubectl create clusterrolebinding app-reader-pods \
  --clusterrole=pod-lister \
  --serviceaccount=apps:app-reader

# Verify
kubectl auth can-i list pods --as=system:serviceaccount:apps:app-reader
# Output: yes
```

---

## Question 12 — Complex RBAC for Developer [4%]

**Solution:**

```bash
kubectl create namespace dev
kubectl create serviceaccount developer -n dev

# Role 1: Deployment management in dev namespace
kubectl create role deployment-manager \
  --verb=get,list,create,update,delete,patch \
  --resource=deployments \
  -n dev

# Role 2: ConfigMap read in dev namespace
kubectl create role config-reader \
  --verb=get,list \
  --resource=configmaps \
  -n dev

# RoleBindings for dev namespace
kubectl create rolebinding dev-deploy-role \
  --role=deployment-manager \
  --serviceaccount=dev:developer \
  -n dev

kubectl create rolebinding dev-config-role \
  --role=config-reader \
  --serviceaccount=dev:developer \
  -n dev

# ClusterRole: read-only pod access everywhere
kubectl create clusterrole pod-reader \
  --verb=get,list \
  --resource=pods

# ClusterRoleBinding
kubectl create clusterrolebinding developer-pods \
  --clusterrole=pod-reader \
  --serviceaccount=dev:developer
```

**Verification:**
```bash
kubectl auth can-i update deployments -n dev --as=system:serviceaccount:dev:developer
# Output: yes
kubectl auth can-i delete deployments -n dev --as=system:serviceaccount:dev:developer
# Output: yes
kubectl auth can-i list configmaps -n dev --as=system:serviceaccount:dev:developer
# Output: yes
kubectl auth can-i list pods -n default --as=system:serviceaccount:dev:developer
# Output: yes
kubectl auth can-i create pods -n default --as=system:serviceaccount:dev:developer
# Output: no
```

---

## Question 13 — Restrictive SecurityContext with tmpfs [5%]

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: restricted
  namespace: secure
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    runAsGroup: 3001
    fsGroup: 2001
  containers:
  - name: nginx
    image: nginx:1.25
    securityContext:
      capabilities:
        drop:
        - ALL
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    - name: var-cache
      mountPath: /var/cache/nginx
    - name: var-run
      mountPath: /var/run
  volumes:
  - name: tmp
    emptyDir: {}
  - name: var-cache
    emptyDir: {}
  - name: var-run
    emptyDir: {}
```

**Note:** nginx needs writable temporary directories despite `readOnlyRootFilesystem: true`, hence the emptyDir volumes.

**Verification:**
```bash
kubectl apply -f restricted.yaml -n secure
kubectl get pod restricted -n secure -o yaml | grep -A 15 "securityContext"
```

---

## Question 14 — Pod with Continuous Logging [4%]

**Solution:**

```bash
kubectl create namespace monitoring

# Create pod
kubectl run log-generator \
  --image=busybox \
  --command -- sh -c 'while true; do echo "$(date): Processing..."; sleep 2; done' \
  -n monitoring
```

Or YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: log-generator
  namespace: monitoring
spec:
  containers:
  - name: logger
    image: busybox
    command: ["sh", "-c", "while true; do echo \"$(date): Processing...\"; sleep 2; done"]
```

**Verification:**
```bash
kubectl logs log-generator -n monitoring --tail=5
# Shows last 5 lines
kubectl logs log-generator -n monitoring --timestamps=true
# Shows with timestamps
kubectl logs log-generator -n monitoring -f
# Follow logs in real-time
```

---

## Question 15 — CronJob [4%]

**Solution:**

```bash
kubectl create namespace jobs

# Create CronJob
kubectl create cronjob backup-job \
  --image=busybox \
  --schedule="0 2 * * *" \
  -n jobs \
  -- sh -c 'echo "Backup started at $(date)" && sleep 10 && echo "Backup complete'
```

Or YAML (recommended for fine-tuning):

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
  namespace: jobs
spec:
  schedule: "0 2 * * *"
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command: ["sh", "-c", "echo 'Backup started at $(date)' && sleep 10 && echo 'Backup complete'"]
          restartPolicy: OnFailure
```

**Verification:**
```bash
kubectl apply -f backup-job.yaml
kubectl get cronjob -n jobs
kubectl get jobs -n jobs
# Watch jobs being created at 02:00 each day
```

---

## Question 16 — DaemonSet with Tolerations [5%]

**Solution:**

```bash
kubectl create namespace advanced
```

DaemonSet YAML:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-monitor
  namespace: advanced
spec:
  selector:
    matchLabels:
      app: node-monitor
  template:
    metadata:
      labels:
        app: node-monitor
    spec:
      nodeSelector:
        kubernetes.io/os: linux
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      containers:
      - name: monitor
        image: busybox
        command: ["sh", "-c", "while true; do echo \"Node: $(hostname)\"; sleep 30; done"]
        resources:
          requests:
            cpu: 50m
            memory: 32Mi
```

**Verification:**
```bash
kubectl apply -f node-monitor.yaml
kubectl get daemonset -n advanced
kubectl get pods -n advanced -o wide
# Should show one pod per node (including control plane if toleration works)
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
| 6 | Configuration | 5% | Hard | 6-8 min |
| 7 | Configuration | 4% | Medium | 4-5 min |
| 8 | Networking | 5% | Hard | 6-8 min |
| 9 | Networking | 4% | Medium | 4-5 min |
| 10 | Networking | 5% | Hard | 6-8 min |
| 11 | RBAC | 3% | Easy | 2-3 min |
| 12 | RBAC | 4% | Medium | 4-5 min |
| 13 | Security | 5% | Hard | 6-8 min |
| 14 | Observability | 4% | Medium | 4-5 min |
| 15 | Design & Build | 4% | Medium | 4-5 min |
| 16 | Design & Build | 5% | Hard | 6-8 min |

---

## Back to Mock Exam

[← Return to MOCK-EXAM-02](MOCK-EXAM-02.md)
