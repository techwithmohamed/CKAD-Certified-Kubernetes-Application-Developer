# Exercise 6 — Deployment + Rolling Update + Rollback

> Related: [Application Deployment](../../README.md#2-application-deployment-20) | [YAML Skeleton: Deployment](../../skeletons/deployment.yaml)

Practice creating deployments with rolling update strategy and performing rollbacks.

## Task

1. Create namespace `exercise-06`
2. Create a Deployment `webapp` with image `nginx:1.24`, 4 replicas, in that namespace
3. Set rolling update strategy: `maxSurge=1`, `maxUnavailable=0`
4. Update the image to `nginx:1.25` and watch the rollout
5. Check rollout history
6. Rollback to the previous revision
7. Verify the image is back to `nginx:1.24`

## Hints

- Generate the deployment YAML with `kubectl create deployment --dry-run=client -o yaml`
- Edit to add `strategy.rollingUpdate` before applying
- Use `kubectl rollout status`, `kubectl rollout history`, `kubectl rollout undo`

## Verify

```bash
kubectl rollout history deployment/webapp -n exercise-06
kubectl get deployment webapp -n exercise-06 -o jsonpath='{.spec.template.spec.containers[0].image}'
# Should show nginx:1.24 after rollback
```

## Cleanup

```bash
kubectl delete namespace exercise-06
```

<details>
<summary>Solution</summary>

```bash
kubectl create namespace exercise-06
kubectl create deployment webapp --image=nginx:1.24 --replicas=4 -n exercise-06 --dry-run=client -o yaml > deploy.yaml
```

Edit `deploy.yaml` to add strategy:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: exercise-06
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: nginx:1.24
```

```bash
kubectl apply -f deploy.yaml
kubectl set image deployment/webapp nginx=nginx:1.25 -n exercise-06
kubectl rollout status deployment/webapp -n exercise-06
kubectl rollout history deployment/webapp -n exercise-06
kubectl rollout undo deployment/webapp -n exercise-06
kubectl get deployment webapp -n exercise-06 -o jsonpath='{.spec.template.spec.containers[0].image}'
```

</details>
