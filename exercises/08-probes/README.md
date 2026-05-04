# Exercise 8 — Probes (Liveness, Readiness, Startup) `Medium`

> Related: [Observability and Maintenance](../../README.md#3-application-observability-and-maintenance-15)

Practice adding all three probe types to pods.

## Task

1. Create namespace `exercise-08`
2. Create a pod `probe-test` with image `nginx` and:
   - Liveness probe: HTTP GET on `/` port 80, period 10s
   - Readiness probe: TCP socket on port 80, initial delay 5s, period 5s
   - Startup probe: HTTP GET on `/` port 80, failure threshold 30, period 10s
3. Verify all probes are configured and the pod is ready

## Hints

- Add probes under `spec.containers[0]`
- Startup probe prevents liveness from killing slow-starting apps

## Gotchas

- **Liveness vs Readiness confusion** — liveness failure = container restart; readiness failure = removed from service endpoints (no restart)
- **Missing startup probe on slow apps** — without it, the liveness probe can kill the container before it finishes starting, causing a restart loop
- **Wrong `initialDelaySeconds`** — set it too low and the probe fires before the app is ready; set it too high and failures take forever to detect
- **`httpGet` path must return 200-399** — a 404 response is treated as a probe failure
- **Port mismatch** — the probe port must match what the container actually listens on, not the service port

## Verify

```bash
kubectl describe pod probe-test -n exercise-08 | grep -A 3 "Liveness\|Readiness\|Startup"
kubectl get pod probe-test -n exercise-08  # should show 1/1 Ready
```

## Cleanup

```bash
kubectl delete namespace exercise-08
```

<details>
<summary>Solution</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-test
  namespace: exercise-08
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 10
    readinessProbe:
      tcpSocket:
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
    startupProbe:
      httpGet:
        path: /
        port: 80
      failureThreshold: 30
      periodSeconds: 10
```

</details>
