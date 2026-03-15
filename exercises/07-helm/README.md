# Exercise 7 — Helm `Medium`

> Related: [Application Deployment](../../README.md#2-application-deployment-20)

Practice adding repos, installing charts, upgrading releases, and rolling back.

## Task

1. Add the Bitnami Helm repository
2. Create namespace `exercise-07`
3. Install a release named `myredis` using chart `bitnami/redis` in that namespace
4. List releases to verify
5. Upgrade the release to set `replica.replicaCount=3`
6. Check the revision number
7. Rollback to revision 1
8. Uninstall the release

## Hints

- `helm repo add`, `helm repo update`
- `helm install <release> <chart> -n <ns>`
- `helm upgrade <release> <chart> -n <ns> --set key=value`
- `helm rollback <release> <revision> -n <ns>`

## Verify

```bash
helm list -n exercise-07
helm history myredis -n exercise-07
```

## Cleanup

```bash
helm uninstall myredis -n exercise-07
kubectl delete namespace exercise-07
```

<details>
<summary>Solution</summary>

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
kubectl create namespace exercise-07
helm install myredis bitnami/redis -n exercise-07
helm list -n exercise-07
helm upgrade myredis bitnami/redis -n exercise-07 --set replica.replicaCount=3
helm history myredis -n exercise-07
helm rollback myredis 1 -n exercise-07
helm uninstall myredis -n exercise-07
```

</details>
