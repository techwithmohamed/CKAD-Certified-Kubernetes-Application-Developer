# Exercise 12 — DaemonSet `Medium`

> Related: [Application Design and Build](../../README.md#1-application-design-and-build-20) | [YAML Skeleton: DaemonSet](../../skeletons/daemonset.yaml)

Practice creating DaemonSets for node-level workloads like logging agents and monitors.

## Task

1. Create namespace `exercise-12`
2. Create a DaemonSet `log-collector` with:
   - Image `fluentd:v1.16-1`
   - Labels `app=log-collector`
   - Mount the host path `/var/log` to `/host-logs` (read-only)
   - Set resource requests: CPU `50m`, memory `64Mi`
   - Set resource limits: CPU `100m`, memory `128Mi`
3. Verify that exactly one pod is running on each node
4. Add a toleration so the DaemonSet also runs on control-plane nodes (taint key `node-role.kubernetes.io/control-plane`)
5. Verify the pod count matches the total number of nodes

## Hints

- DaemonSets have no `replicas` field — Kubernetes schedules exactly one pod per matching node
- Use `hostPath` volume type to access node-level logs
- Tolerations allow pods to be scheduled on tainted nodes
- Use `kubectl get pods -o wide` to see which node each pod runs on

## Verify

```bash
kubectl get daemonset log-collector -n exercise-12
kubectl get pods -n exercise-12 -o wide
kubectl get nodes --no-headers | wc -l
# Pod count should equal node count (after adding control-plane toleration)
```

## Cleanup

```bash
kubectl delete namespace exercise-12
```

<details>
<summary>Solution</summary>

```bash
kubectl create namespace exercise-12
```

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
  namespace: exercise-12
spec:
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluentd:v1.16-1
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
        volumeMounts:
        - name: host-logs
          mountPath: /host-logs
          readOnly: true
      volumes:
      - name: host-logs
        hostPath:
          path: /var/log
          type: Directory
```

```bash
kubectl apply -f daemonset.yaml
kubectl get daemonset log-collector -n exercise-12
kubectl get pods -n exercise-12 -o wide
```

</details>
