# Exercise 10 — SecurityContext + PVC

Practice pod security settings and persistent storage.

## Task A — SecurityContext

1. Create namespace `exercise-10`
2. Create a pod `locked-down` with image `nginx` that:
   - Runs as user 1000, group 3000
   - Sets fsGroup 2000
   - Drops ALL capabilities
   - Disallows privilege escalation
   - Uses a read-only root filesystem
3. The pod will crash because nginx needs to write to `/var/cache/nginx` — fix it by adding an `emptyDir` volume at that path

## Task B — PVC

4. Create a PVC `data-pvc` requesting 256Mi with access mode `ReadWriteOnce`
5. Create a pod `writer` with image `busybox` (command: `sleep 3600`) that mounts the PVC at `/data`
6. Exec into the pod and create a file at `/data/test.txt`
7. Delete the pod, recreate it, and verify the file still exists

## Cleanup

```bash
kubectl delete namespace exercise-10
```

<details>
<summary>Solution — SecurityContext</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: locked-down
  namespace: exercise-10
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: nginx
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
    volumeMounts:
    - name: cache
      mountPath: /var/cache/nginx
    - name: run
      mountPath: /var/run
  volumes:
  - name: cache
    emptyDir: {}
  - name: run
    emptyDir: {}
```

</details>

<details>
<summary>Solution — PVC</summary>

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
  namespace: exercise-10
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 256Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: writer
  namespace: exercise-10
spec:
  containers:
  - name: writer
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data-pvc
```

```bash
kubectl apply -f pvc-pod.yaml
kubectl exec writer -n exercise-10 -- sh -c 'echo hello > /data/test.txt'
kubectl delete pod writer -n exercise-10
kubectl apply -f pvc-pod.yaml   # only the pod part
kubectl exec writer -n exercise-10 -- cat /data/test.txt
# Should output: hello
```

</details>
