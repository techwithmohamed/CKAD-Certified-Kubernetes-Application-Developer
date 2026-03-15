# Exercise 9 — Ingress + Gateway API `Hard`

> Related: [Services and Networking](../../README.md#5-services-and-networking-20) | [YAML Skeletons: Ingress](../../skeletons/ingress.yaml) | [Gateway API](../../skeletons/gateway-api.yaml)

Practice creating Ingress resources and Gateway API HTTPRoutes.

## Task A — Ingress

1. Create namespace `exercise-09`
2. Create two deployments: `shop` (image `nginx`) and `cart` (image `nginx`) with matching services on port 80
3. Create an Ingress `store-ingress` that routes:
   - `store.example.com/shop` → `shop-svc:80`
   - `store.example.com/cart` → `cart-svc:80`

## Task B — Gateway API HTTPRoute

4. Assume a GatewayClass `example-gc` and Gateway `store-gw` already exist
5. Create an HTTPRoute `store-route` that routes the same paths to the same services

## Hints

- Ingress uses `pathType: Prefix`
- HTTPRoute uses `parentRefs` to attach to a Gateway
- Gateway API uses `type: PathPrefix` under `matches`

## Cleanup

```bash
kubectl delete namespace exercise-09
```

<details>
<summary>Solution — Ingress</summary>

```bash
kubectl create namespace exercise-09
kubectl create deployment shop --image=nginx -n exercise-09
kubectl expose deployment shop --port=80 --name=shop-svc -n exercise-09
kubectl create deployment cart --image=nginx -n exercise-09
kubectl expose deployment cart --port=80 --name=cart-svc -n exercise-09
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: store-ingress
  namespace: exercise-09
spec:
  rules:
  - host: store.example.com
    http:
      paths:
      - path: /shop
        pathType: Prefix
        backend:
          service:
            name: shop-svc
            port:
              number: 80
      - path: /cart
        pathType: Prefix
        backend:
          service:
            name: cart-svc
            port:
              number: 80
```

</details>

<details>
<summary>Solution — Gateway API HTTPRoute</summary>

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: store-route
  namespace: exercise-09
spec:
  parentRefs:
  - name: store-gw
  hostnames:
  - "store.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /shop
    backendRefs:
    - name: shop-svc
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /cart
    backendRefs:
    - name: cart-svc
      port: 80
```

</details>
