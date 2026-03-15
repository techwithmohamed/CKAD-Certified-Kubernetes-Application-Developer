# Exercise 13 — Init Containers `Medium`

> Related: [Application Design and Build](../../README.md#1-application-design-and-build-20) | [YAML Skeleton: Pod](../../skeletons/pod.yaml)

Practice using init containers for dependency checking, data seeding, and migration workflows.

## Task A — Dependency Check

1. Create namespace `exercise-13`
2. Create a pod `web-app` with:
   - An init container `wait-for-db` using image `busybox` that waits until a service `db-svc` is resolvable via DNS: `until nslookup db-svc.exercise-13.svc.cluster.local; do echo waiting; sleep 2; done`
   - A main container `app` using image `nginx`
3. Observe the pod stuck in `Init:0/1` status (because `db-svc` does not exist yet)
4. Create a Service `db-svc` on port 5432 (no backing pods needed — just the Service object)
5. Watch the init container complete and the main container start

## Task B — Multi-Init Containers

6. Create a pod `multi-init` with:
   - Init container `init-config` using `busybox` that writes `CONFIG_READY=true` to `/work/config.txt`
   - Init container `init-schema` using `busybox` that appends `SCHEMA_READY=true` to `/work/config.txt`
   - Main container `app` using `busybox` with command: `cat /work/config.txt && sleep 3600`
   - A shared `emptyDir` volume mounted at `/work` for all containers
7. Verify init containers run in order and the main container sees both values

## Hints

- Init containers run sequentially in the order they are listed
- Each init container must exit successfully (exit code 0) before the next one starts
- Init containers have the same volume access as regular containers
- Use `kubectl describe pod` to see init container status in the Events section

## Verify

```bash
# Task A
kubectl get pod web-app -n exercise-13
# Before creating db-svc: status should be Init:0/1
# After creating db-svc: status should be Running

# Task B
kubectl logs multi-init -n exercise-13 -c app
# Should show both CONFIG_READY=true and SCHEMA_READY=true
```

## Cleanup

```bash
kubectl delete namespace exercise-13
```

<details>
<summary>Solution — Task A</summary>

```bash
kubectl create namespace exercise-13
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
  namespace: exercise-13
spec:
  initContainers:
  - name: wait-for-db
    image: busybox
    command: ["sh", "-c", "until nslookup db-svc.exercise-13.svc.cluster.local; do echo waiting for db-svc; sleep 2; done"]
  containers:
  - name: app
    image: nginx
```

```bash
kubectl apply -f web-app.yaml
kubectl get pod web-app -n exercise-13
# Status: Init:0/1

# Now create the service so the init container can resolve it
kubectl create service clusterip db-svc --tcp=5432:5432 -n exercise-13

# Watch the pod transition to Running
kubectl get pod web-app -n exercise-13 -w
```

</details>

<details>
<summary>Solution — Task B</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-init
  namespace: exercise-13
spec:
  initContainers:
  - name: init-config
    image: busybox
    command: ["sh", "-c", "echo CONFIG_READY=true > /work/config.txt"]
    volumeMounts:
    - name: workdir
      mountPath: /work
  - name: init-schema
    image: busybox
    command: ["sh", "-c", "echo SCHEMA_READY=true >> /work/config.txt"]
    volumeMounts:
    - name: workdir
      mountPath: /work
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "cat /work/config.txt && sleep 3600"]
    volumeMounts:
    - name: workdir
      mountPath: /work
  volumes:
  - name: workdir
    emptyDir: {}
```

```bash
kubectl apply -f multi-init.yaml
kubectl get pod multi-init -n exercise-13
kubectl logs multi-init -n exercise-13 -c app
# Output:
# CONFIG_READY=true
# SCHEMA_READY=true
```

</details>
