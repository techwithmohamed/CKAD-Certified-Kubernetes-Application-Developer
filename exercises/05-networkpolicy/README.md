# Exercise 5 — NetworkPolicy

> Related: [Services and Networking](../../README.md#5-services-and-networking-20) | [YAML Skeleton: NetworkPolicy](../../skeletons/networkpolicy.yaml)

Practice writing NetworkPolicies with ingress and egress rules, including the DNS egress gotcha.

## Task

1. Create namespace `exercise-05`
2. Create three pods in that namespace:
   - `frontend` with label `role=frontend` (image: `nginx`)
   - `api` with label `role=api` (image: `nginx`)
   - `db` with label `role=db` (image: `nginx`)
3. Create a NetworkPolicy `api-policy` that:
   - Applies to pods with label `role=api`
   - Allows ingress only from pods labeled `role=frontend` on port 80
   - Allows egress only to pods labeled `role=db` on port 5432
   - Allows DNS egress (UDP port 53) to any namespace
   - Denies all other traffic

## Hints

- Don't forget `policyTypes: [Ingress, Egress]` — without this the rules won't apply
- Always include DNS egress or pod-to-service resolution breaks
- Use `namespaceSelector: {}` for DNS egress (matches all namespaces)

## Verify

```bash
kubectl describe networkpolicy api-policy -n exercise-05
```

## Cleanup

```bash
kubectl delete namespace exercise-05
```

<details>
<summary>Solution</summary>

```bash
kubectl create namespace exercise-05
kubectl run frontend --image=nginx -n exercise-05 -l role=frontend
kubectl run api --image=nginx -n exercise-05 -l role=api
kubectl run db --image=nginx -n exercise-05 -l role=db
```

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-policy
  namespace: exercise-05
spec:
  podSelector:
    matchLabels:
      role: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: db
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
```

</details>
