# Exercise 3 — ConfigMap + Secret Injection

Practice creating ConfigMaps and Secrets and injecting them into pods as env vars and volumes.

## Task

1. Create namespace `exercise-03`
2. Create a ConfigMap `app-config` with keys `DB_HOST=mysql.default.svc` and `LOG_LEVEL=debug`
3. Create a Secret `db-creds` with keys `username=admin` and `password=ckad2026`
4. Create a pod `config-app` using image `nginx` that:
   - Loads all ConfigMap keys as environment variables using `envFrom`
   - Mounts the Secret as a volume at `/etc/db-creds` (read-only)
5. Verify the env vars and mounted files

## Hints

- `kubectl create configmap` and `kubectl create secret generic` with `--from-literal`
- Use `envFrom.configMapRef` for bulk env loading
- Use `volumes[].secret.secretName` for volume mount

## Verify

```bash
kubectl exec config-app -n exercise-03 -- env | grep -E "DB_HOST|LOG_LEVEL"
kubectl exec config-app -n exercise-03 -- cat /etc/db-creds/username
kubectl exec config-app -n exercise-03 -- cat /etc/db-creds/password
```

## Cleanup

```bash
kubectl delete namespace exercise-03
```

<details>
<summary>Solution</summary>

```bash
kubectl create namespace exercise-03
kubectl create configmap app-config -n exercise-03 --from-literal=DB_HOST=mysql.default.svc --from-literal=LOG_LEVEL=debug
kubectl create secret generic db-creds -n exercise-03 --from-literal=username=admin --from-literal=password=ckad2026
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-app
  namespace: exercise-03
spec:
  containers:
  - name: nginx
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
    volumeMounts:
    - name: secret-vol
      mountPath: /etc/db-creds
      readOnly: true
  volumes:
  - name: secret-vol
    secret:
      secretName: db-creds
```

</details>
