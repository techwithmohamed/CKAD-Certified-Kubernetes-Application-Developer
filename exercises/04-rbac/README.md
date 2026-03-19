# Exercise 4 — RBAC (Role + RoleBinding + ServiceAccount) `Medium`

> Related: [Environment, Configuration, and Security](../../README.md#4-application-environment-configuration-and-security-25) | [YAML Skeleton: RBAC](../../skeletons/rbac.yaml)

Practice creating RBAC rules that restrict what a ServiceAccount can do.

## Task

1. Create namespace `exercise-04`
2. Create a ServiceAccount `app-sa` in that namespace
3. Create a Role `pod-manager` that allows `get`, `list`, `watch`, and `create` on `pods`
4. Create a RoleBinding `app-sa-binding` that binds the Role to the ServiceAccount
5. Verify the ServiceAccount CAN list pods but CANNOT delete them

## Hints

- Use imperative commands: `kubectl create role`, `kubectl create rolebinding`
- Use `kubectl auth can-i` with `--as=system:serviceaccount:<ns>:<sa>` to verify

## Gotchas

- **Role vs ClusterRole** — a `Role` is namespaced; a `ClusterRole` is cluster-wide. Using the wrong one means permissions don't apply where you expect
- **RoleBinding must reference the correct ServiceAccount namespace** — the `subjects[].namespace` field matters. Getting it wrong silently grants nothing
- **The `--as` flag format** — it's `system:serviceaccount:<namespace>:<name>`, not just the SA name. Missing the prefix returns `forbidden` even with correct bindings
- **Verbs are case-sensitive** — `Get` won't work, it must be lowercase `get`

## Verify

```bash
kubectl auth can-i list pods --as=system:serviceaccount:exercise-04:app-sa -n exercise-04
# yes
kubectl auth can-i delete pods --as=system:serviceaccount:exercise-04:app-sa -n exercise-04
# no
kubectl auth can-i create pods --as=system:serviceaccount:exercise-04:app-sa -n exercise-04
# yes
```

## Cleanup

```bash
kubectl delete namespace exercise-04
```

<details>
<summary>Solution</summary>

```bash
kubectl create namespace exercise-04
kubectl create serviceaccount app-sa -n exercise-04
kubectl create role pod-manager --verb=get,list,watch,create --resource=pods -n exercise-04
kubectl create rolebinding app-sa-binding --role=pod-manager --serviceaccount=exercise-04:app-sa -n exercise-04
```

</details>
