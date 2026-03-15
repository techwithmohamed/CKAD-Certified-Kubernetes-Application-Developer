# Exercise 11 — StatefulSet `Hard`

> Related: [Application Design and Build](../../README.md#1-application-design-and-build-20) | [YAML Skeleton: StatefulSet](../../skeletons/statefulset.yaml)

Practice creating StatefulSets with stable identities, headless Services, and persistent storage.

## Task

1. Create namespace `exercise-11`
2. Create a headless Service `db-headless` (clusterIP: None) targeting port 5432 with selector `app=db`
3. Create a StatefulSet `db` with:
   - Image `postgres:16-alpine`
   - 3 replicas
   - Selector and pod labels `app=db`
   - The headless Service name `db-headless` as `serviceName`
   - Environment variable `POSTGRES_PASSWORD=exam123` (from a Secret you create)
   - A `volumeClaimTemplate` named `data` requesting 1Gi (ReadWriteOnce), mounted at `/var/lib/postgresql/data`
4. Verify that pods are created in order: `db-0`, `db-1`, `db-2`
5. Verify each pod gets a stable DNS name: `db-0.db-headless.exercise-11.svc.cluster.local`
6. Delete `db-1` and verify it comes back with the same name and same PVC

## Hints

- A headless Service requires `clusterIP: None`
- StatefulSet pods are created sequentially (0 → 1 → 2) and deleted in reverse
- Each pod gets a DNS record: `<pod-name>.<service-name>.<namespace>.svc.cluster.local`
- `volumeClaimTemplates` creates a unique PVC per pod (e.g., `data-db-0`, `data-db-1`)
- Use `kubectl run tmp --image=busybox --rm -it -- nslookup db-0.db-headless.exercise-11` to test DNS

## Verify

```bash
kubectl get statefulset db -n exercise-11
kubectl get pods -n exercise-11 -l app=db -o wide
kubectl get pvc -n exercise-11
# Should see: data-db-0, data-db-1, data-db-2

# Test stable DNS
kubectl run dns-test --image=busybox --rm -it -n exercise-11 -- nslookup db-0.db-headless.exercise-11.svc.cluster.local

# Delete db-1 and watch it return
kubectl delete pod db-1 -n exercise-11
kubectl get pods -n exercise-11 -w
```

## Cleanup

```bash
kubectl delete namespace exercise-11
```

<details>
<summary>Solution</summary>

```bash
kubectl create namespace exercise-11
kubectl create secret generic db-secret --from-literal=POSTGRES_PASSWORD=exam123 -n exercise-11
```

```yaml
# headless-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: db-headless
  namespace: exercise-11
spec:
  clusterIP: None
  selector:
    app: db
  ports:
  - port: 5432
    targetPort: 5432
---
# statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db
  namespace: exercise-11
spec:
  serviceName: db-headless
  replicas: 3
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: postgres
        image: postgres:16-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: POSTGRES_PASSWORD
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
```

```bash
kubectl apply -f headless-service.yaml
kubectl apply -f statefulset.yaml

# Watch ordered creation
kubectl get pods -n exercise-11 -w

# Verify PVCs
kubectl get pvc -n exercise-11

# Test stable DNS
kubectl run dns-test --image=busybox --rm -it -n exercise-11 -- nslookup db-0.db-headless.exercise-11.svc.cluster.local

# Delete db-1 — it comes back with same name + same PVC
kubectl delete pod db-1 -n exercise-11
kubectl get pods -n exercise-11 -w
```

</details>
