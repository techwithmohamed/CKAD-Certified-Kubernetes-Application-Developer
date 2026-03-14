# Exercise 1 — Pod Basics

> Related: [Application Design and Build](../../README.md#1-application-design-and-build-20) | [YAML Skeleton: Pod](../../skeletons/pod.yaml)

Create a pod with resource limits, labels, and verify it's running.

## Task

1. Create namespace `exercise-01`
2. Create a pod named `web` in that namespace with image `nginx:1.25`
3. Add labels `app=web` and `tier=frontend`
4. Set CPU request `100m`, memory request `128Mi`, CPU limit `250m`, memory limit `256Mi`
5. Verify the pod is running and labels are correct

## Hints

- Use `kubectl run` with `--dry-run=client -o yaml` to generate the scaffold
- Edit the YAML to add resources before applying

## Verify

```bash
kubectl get pod web -n exercise-01 --show-labels
kubectl describe pod web -n exercise-01 | grep -A 4 "Limits\|Requests"
```

## Cleanup

```bash
kubectl delete namespace exercise-01
```

<details>
<summary>Solution</summary>

```bash
kubectl create namespace exercise-01
kubectl run web --image=nginx:1.25 -n exercise-01 --labels="app=web,tier=frontend" --dry-run=client -o yaml > pod.yaml
```

Edit `pod.yaml` to add resources:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  namespace: exercise-01
  labels:
    app: web
    tier: frontend
spec:
  containers:
  - name: web
    image: nginx:1.25
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 250m
        memory: 256Mi
```

```bash
kubectl apply -f pod.yaml
```

</details>
