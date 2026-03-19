# Exercise 5 — NetworkPolicy `Hard`

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

## Gotchas

- **Forgetting DNS egress** — the classic trap. Without allowing UDP 53, pods can't resolve service names even though the data-plane rules look correct
- **`policyTypes` field** — if you write `egress` rules but don't include `Egress` in `policyTypes`, the egress rules are silently ignored. Same for `Ingress`
- **Empty `podSelector: {}`** — this selects ALL pods in the namespace, not none. Use it carefully in the policy target
- **NetworkPolicies are additive** — there's no "deny" rule. If ANY policy allows the traffic, it's allowed. A default-deny policy is an empty ingress/egress list
- **CNI must support NetworkPolicy** — kind uses kindnet (no support) by default; use Calico or Cilium to test

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
