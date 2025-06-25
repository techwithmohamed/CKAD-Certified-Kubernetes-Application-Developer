[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

# ☸️  Certified Kubernetes Application Developer (CKAD) Exam Guide - V1.33 (2025)

<p align="center">
  <img src="ckad.png" alt="CKAD EXAM 2025">
</p>

> This guide is part of our blog [How to Pass Certified Kubernetes Application Developer (CKAD) 2025 ](https://techwithmohamed.com/blog/ckad-exam-study-guide/).

## Hit the Star! :star:
> If you are using this repo for guidance, please hit the star. Thanks A lot !

The [Certified Kubernetes Application Developer (CKAD) certification](https://www.cncf.io/certification/ckad/) exam certifies that candidates can design, build and deploy cloud-native applications for Kubernetes.

## 📋 CKAD Exam Details (Updated June 2025)

| **Detail**                      | **Description**                                                                 |
|-------------------------------|---------------------------------------------------------------------------------|
| 🧪 **Exam Format**             | Hands-on, performance-based (No MCQs)                                           |
| ⏱️ **Duration**                | 2 hours                                                                         |
| 🎯 **Passing Score**           | 66%                                                                             |
| 📦 **Kubernetes Version**      | [Kubernetes v1.33](https://kubernetes.io/blog/2025/04/23/kubernetes-v1-33-release/)                            |
| 🗓️ **Certification Validity** | 2 years                                                                         |
| 💰 **Exam Cost**               | $445 USD                                                                        |
| 🌐 **Proctoring Platform**     | Remote — PSI Bridge (secure browser required)                                  |
| 📚 **Open Book Resources**     | [kubernetes.io](https://kubernetes.io), GitHub, Kubernetes blog & subdomains   |

> ✅ Tip: Always verify version and exam updates via the [official CKAD page](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/).


## 📘 CKAD Exam Syllabus (Kubernetes v1.33 – Updated June 2025)

| **🧩 Domain** | **📋 Key Concepts** | **🎯 Weight** |
|--------------|---------------------|---------------|
| 🛠️[**Application Design and Build - 20%**](#-application-design-and-build-20) | - Define, build and modify container images<br>- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)<br>- Understand multi-container Pod design patterns (e.g. sidecar, init and others)<br>- Utilize persistent and ephemeral volumes | 20% |
| 🚀 [**Application Deployment - 20%**](#application-deployment-20) | - Use Kubernetes primitives to implement common deployment strategies (e.g. blue/green or canary)<br>- Understand Deployments and how to perform rolling updates<br>- Use the Helm package manager to deploy existing packages<br>- Kustomize | 20% |
| 🔍 [**Application Observability and Maintenance - 15%**](#application-observability-and-maintenance-15) | - Understand API deprecations<br>- Implement probes and health checks<br>- Use built-in CLI tools to monitor Kubernetes applications<br>- Utilize container logs<br>- Debugging in Kubernetes | 15% |
| 🔐  [**Application Environment, Configuration, and Security - 25%**](#-application-environment-configuration-and-security-25) | - Discover and use resources that extend Kubernetes (CRD, Operators)<br>- Understand authentication, authorization and admission control<br>- Understand requests, limits, quotas<br>- Understand ConfigMaps<br>- Define resource requirements<br>- Create & consume Secrets<br>- Understand ServiceAccounts<br>- Understand Application Security (SecurityContexts, Capabilities, etc.) | 25% |
| 🌐  [**Services & Networking - 20%**](#services-and-networking-20) | - Demonstrate basic understanding of NetworkPolicies<br>- Provide and troubleshoot access to applications via services<br>- Use Ingress rules to expose applications | 20% |


## 📦 Application Design and Build (20%)

This domain focuses on your ability to build containers, choose appropriate workloads, and design Pods for real-world scenarios. You’ll need to be comfortable working with multi-container Pods and both persistent and ephemeral volumes.

### 🛠️ 1. Define, Build, and Modify Container Images

Being able to package your application in a container image is fundamental in Kubernetes. You'll often be asked to use a custom Dockerfile or make small changes to existing images.

#### ✅ Real-World Task:

Create a simple NGINX container that serves a custom homepage.

```Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

```bash
docker build -t your-dockerhub-username/custom-nginx:latest .
docker push your-dockerhub-username/custom-nginx:latest
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: custom-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: your-dockerhub-username/custom-nginx:latest
```

```bash
kubectl apply -f deployment.yaml
```

👉 [Kubernetes: Container Images](https://kubernetes.io/docs/concepts/containers/images/)

---

### 📂 2. Choose and Use the Right Workload Resource

Different workloads solve different problems. Use `Deployment` for scalable apps, `CronJob` for scheduled tasks, and `DaemonSet` when something needs to run on all nodes.

#### ✅ Real-World Task:

Create a `CronJob` to run a backup every night at 2 AM.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            args:
            - "/bin/sh"
            - "-c"
            - "echo Backup complete"
          restartPolicy: OnFailure
```

```bash
kubectl apply -f cronjob.yaml
```

👉 [Kubernetes: Workloads Overview](https://kubernetes.io/docs/concepts/workloads/)

---

### 🧱 3. Understand Multi-Container Pod Design Patterns

Sometimes, your Pod needs more than one container—for example, a logging sidecar or an init container that sets up preconditions.

#### ✅ Real-World Task:

Log everything from the main app using a sidecar container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-example
spec:
  containers:
  - name: main-app
    image: busybox
    command: ["sh", "-c", "echo Hello World; sleep 3600"]
  - name: sidecar
    image: busybox
    command: ["sh", "-c", "tail -f /var/log/app.log"]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  volumes:
  - name: log-volume
    emptyDir: {}
```

```bash
kubectl apply -f pod.yaml
```

👉 [Pod Design Patterns](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)

---

### 💾 4. Utilize Persistent and Ephemeral Volumes

You’ll be tested on when to use `emptyDir` vs `PersistentVolumeClaim` (PVC) for Pod storage.

#### ✅ Real-World Task:

Attach persistent storage to a web server.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-example
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-pvc
spec:
  containers:
  - name: app-container
    image: nginx
    volumeMounts:
    - mountPath: /usr/share/nginx/html
      name: storage
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: pvc-example
```

```bash
kubectl apply -f pvc.yaml
kubectl apply -f pod.yaml
```

👉 [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) 👉 [Ephemeral Volumes](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir)

---

## 🔐 Application Environment, Configuration, and Security (25%)

This domain accounts for **25% of the CKAD 2025 exam**. It focuses on managing app configurations, sensitive data, security policies, and access controls. These are essential for building secure and production-ready workloads.

### 🔧 1. Discover and Use Resources that Extend Kubernetes (CRDs, Operators)

Custom Resource Definitions (CRDs) and Operators extend Kubernetes with new APIs or automate complex app management.

#### ✅ Real-World Task: Register a custom resource

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.example.com
spec:
  group: example.com
  names:
    kind: Widget
    plural: widgets
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              size:
                type: string
```

```bash
kubectl apply -f crd.yaml
```

👉 [CRDs Overview](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/)

---

### 🔐 2. Understand Authentication, Authorization, and Admission Control

Control who can do what in your cluster with RBAC, and enforce policies with admission controllers.

#### ✅ Real-World Task: Create a Role and RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

👉 [RBAC Docs](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

---

### 📏 3. Understand Requests, Limits, and Quotas

Resource constraints are essential in multi-tenant clusters. Use them to control CPU/memory allocation.

```yaml
resources:
  requests:
    cpu: "250m"
    memory: "64Mi"
  limits:
    cpu: "500m"
    memory: "128Mi"
```

Define a namespace-wide quota:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: "2Gi"
    limits.cpu: "8"
    limits.memory: "4Gi"
```

👉 [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

---

### ⚙️ 4. Understand ConfigMaps

Store app configs outside of code. Pass them into containers as env vars or volumes.

```bash
kubectl create configmap app-config --from-literal=APP_MODE=production
```

Inject into Pod:

```yaml
env:
- name: APP_MODE
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: APP_MODE
```

👉 [ConfigMaps Guide](https://kubernetes.io/docs/concepts/configuration/configmap/)

---

### 🎯 5. Define Resource Requirements

Covered in Section 3 above. Always define `requests` and `limits` to avoid overcommitment and OOM kills.

---

### 🔑 6. Create and Consume Secrets

Manage sensitive info like passwords securely.

```bash
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=secret123
```

Inject into Pod:

```yaml
env:
- name: DB_USERNAME
  valueFrom:
    secretKeyRef:
      name: db-credentials
      key: username
```

👉 [Secrets Overview](https://kubernetes.io/docs/concepts/configuration/secret/)

---

### 🧾 7. Understand ServiceAccounts

Bind processes in Pods to identities that control what they can access in the API.

```bash
kubectl create serviceaccount app-bot
```

```yaml
spec:
  serviceAccountName: app-bot
```

👉 [ServiceAccounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

---

### 🛡️ 8. Understand Application Security (SecurityContexts, Capabilities)

Use SecurityContexts to enforce non-root containers, drop privileges, and isolate file permissions.

```yaml
securityContext:
  runAsUser: 1000
  runAsGroup: 3000
  fsGroup: 2000
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
```

👉 [Security Contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)

---

### 🧠 Practice Tips

- Set default namespaces to avoid misplacing objects:
  ```bash
  kubectl config set-context --current --namespace=my-app
  ```
- Always validate YAML before applying it:
  ```bash
  kubectl apply -f myfile.yaml --dry-run=client -o yaml
  ```
- Explore CRDs and RBAC via `kubectl explain` to understand object structures.

---

### 📚 Additional Study Resources

- [CKAD Curriculum Overview](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)




## Services And Networking (20%)

This domain constitutes 20% of the CKAD Exam. Below are the key topics explained with `kubectl` examples:

### 1. Demonstrate Basic Understanding of NetworkPolicies
NetworkPolicies are used to control the communication between Pods and network endpoints.

#### Example:
**Create a NetworkPolicy to Allow Traffic from a Specific Pod:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-specific-pod
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
```
```bash
kubectl apply -f networkpolicy.yaml
```

**Verify NetworkPolicy:**
```bash
kubectl describe networkpolicy allow-specific-pod
```

- [Learn more about NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

### 2. Provide and Troubleshoot Access to Applications via Services
Services enable access to applications running in Pods.

#### Example:
**Create a ClusterIP Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```
```bash
kubectl apply -f service.yaml
```

**Test Service Access:**
```bash
kubectl get svc my-service
kubectl exec -it <pod-name> -- curl http://my-service
```

**Troubleshoot Service:**
```bash
kubectl describe svc my-service
kubectl get endpoints my-service
```

- [Learn more about Services](https://kubernetes.io/docs/concepts/services-networking/service/)

### 3. Use Ingress Rules to Expose Applications
Ingress exposes HTTP and HTTPS routes to services within the cluster.

#### Example:
**Create an Ingress Resource:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```
```bash
kubectl apply -f ingress.yaml
```

**Verify Ingress:**
```bash
kubectl get ingress example-ingress
```

**Test Ingress Access:**
```bash
curl -H "Host: example.com" <ingress-ip>
```

- [Learn more about Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

---

### Resources to Prepare
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [CKAD Exam Tips](https://kubernetes.io/docs/certifications/)


## Application Deployment (20%)

This domain constitutes 20% of the CKAD Exam. Below are the key topics explained with `kubectl` examples and tools like Helm and Kustomize.

### 1. Use Kubernetes Primitives to Implement Common Deployment Strategies (e.g., Blue/Green or Canary)
Kubernetes provides mechanisms to implement deployment strategies such as blue/green and canary deployments.

#### Blue/Green Deployment Example:
Create two Deployments (blue and green) and switch traffic using a Service:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blue-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
      version: blue
  template:
    metadata:
      labels:
        app: my-app
        version: blue
    spec:
      containers:
      - name: app
        image: my-app:blue
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: green-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
      version: green
  template:
    metadata:
      labels:
        app: my-app
        version: green
    spec:
      containers:
      - name: app
        image: my-app:green
```
Switch the Service to point to the green Deployment:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
    version: green
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```
```bash
kubectl apply -f blue-deployment.yaml
kubectl apply -f green-deployment.yaml
kubectl apply -f service.yaml
```

#### Canary Deployment Example:
Gradually shift traffic to a new version:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: canary-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
      version: canary
  template:
    metadata:
      labels:
        app: my-app
        version: canary
    spec:
      containers:
      - name: app
        image: my-app:canary
```
```bash
kubectl apply -f canary-deployment.yaml
kubectl scale deployment canary-deployment --replicas=3
```

- [Learn more about Deployment Strategies](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

### 2. Understand Deployments and How to Perform Rolling Updates
Deployments manage updates to applications while ensuring zero downtime.

#### Example:
**Create a Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-update-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: app
        image: my-app:v1
```
```bash
kubectl apply -f deployment.yaml
```

**Update the Deployment with a New Image:**
```bash
kubectl set image deployment/rolling-update-demo app=my-app:v2
```
**Monitor the Update:**
```bash
kubectl rollout status deployment/rolling-update-demo
```
**Rollback if Necessary:**
```bash
kubectl rollout undo deployment/rolling-update-demo
```

- [Learn more about Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

### 3. Use the Helm Package Manager to Deploy Existing Packages
Helm simplifies application management by using reusable charts.

#### Example:
**Install Helm and Deploy a Package:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/nginx
```
**Upgrade a Release:**
```bash
helm upgrade my-release bitnami/nginx --set image.tag=latest
```
**Uninstall a Release:**
```bash
helm uninstall my-release
```

- [Learn more about Helm](https://helm.sh/docs/)

### 4. Kustomize
Kustomize allows you to customize Kubernetes manifests without modifying the original files.

#### Example:
**Create a Base Deployment:**
```yaml
# base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kustomize-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: app
        image: my-app:v1
```
**Create an Overlay to Patch the Base:**
```yaml
# overlays/production/patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kustomize-demo
spec:
  replicas: 5
```
**Apply Kustomize:**
```bash
kubectl apply -k overlays/production/
```

- [Learn more about Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)

---

### Resources to Prepare
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [CKAD Exam Tips](https://kubernetes.io/docs/certifications/)


## Application Observability and Maintenance (15%)

This domain constitutes 15% of the CKAD Exam. Below are the key topics explained with `kubectl` examples to enhance your understanding of observability and maintenance.

### 1. Understand API Deprecations
Kubernetes APIs evolve over time. It's essential to understand deprecated APIs and their replacements.

#### Example:
**Check for Deprecated APIs in Manifests:**
```bash
kubectl convert -f deployment-v1beta1.yaml --output-version=apps/v1
```
**Verify Deprecated API Usage in the Cluster:**
```bash
kubectl get events --all-namespaces | grep -i deprecated
```

- [Learn more about API Deprecations](https://kubernetes.io/docs/reference/using-api/deprecation-policy/)

### 2. Implement Probes and Health Checks
Probes ensure application health by checking the status of Pods.

#### Example:
**Add Liveness and Readiness Probes:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: app
        image: my-app:latest
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /readyz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
```
```bash
kubectl apply -f probe-demo.yaml
```
**Check Probe Status:**
```bash
kubectl describe pod <pod-name>
```

- [Learn more about Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

### 3. Use Built-in CLI Tools to Monitor Kubernetes Applications
Kubernetes offers various tools for monitoring application performance and health.

#### Examples:
**View Resource Utilization:**
```bash
kubectl top nodes
kubectl top pods
```
**Describe Resources:**
```bash
kubectl describe pod <pod-name>
kubectl describe node <node-name>
```
**Get Cluster Events:**
```bash
kubectl get events --all-namespaces
```

- [Learn more about Monitoring Tools](https://kubernetes.io/docs/tasks/debug/debug-cluster/)

### 4. Utilize Container Logs
Logs are critical for diagnosing application issues.

#### Example:
**View Logs for a Specific Pod:**
```bash
kubectl logs <pod-name>
```
**Stream Logs:**
```bash
kubectl logs -f <pod-name>
```
**View Logs for a Specific Container in a Pod:**
```bash
kubectl logs <pod-name> -c <container-name>
```

- [Learn more about Container Logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/)

### 5. Debugging in Kubernetes
Debugging involves identifying and resolving issues in Pods, Deployments, or the cluster.

#### Example:
**Get Pod Details:**
```bash
kubectl get pod <pod-name> -o yaml
```
**Exec into a Pod for Debugging:**
```bash
kubectl exec -it <pod-name> -- /bin/bash
```
**Debug a Node:**
```bash
kubectl debug node/<node-name> --image=busybox
```

- [Learn more about Debugging](https://kubernetes.io/docs/tasks/debug/)

---

### Resources to Prepare
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [CKAD Exam Tips](https://kubernetes.io/docs/certifications/)


## CKAD Exam Practice Labs

The best way to prepare is to practice a lot! The setups below will provide you with a Kubernetes cluster where you can perform all the required practice. The CKAD exam expects you to solve problems on a live cluster.

> **Note:** CKAD does not include any multiple-choice questions (MCQs). Hands-on practice is essential!

### Recommended Practice Tools

1. [**Killercoda**](https://killercoda.com): An online interactive platform to practice Kubernetes and other DevOps tools in a realistic environment.
2. [**Minikube**](https://minikube.sigs.k8s.io): A tool that lets you run a Kubernetes cluster locally, ideal for individual practice on your local machine.


## Additional Resources

* 📚 Guide to Kubernetes Application Development](https://teckbootcamps.com/ckad-exam-study-guide/)<sup>Blog</sup>
* 💬 [Kubernetes Slack Channel #certifications](https://kubernetes.slack.com/)<sup>Slack</sup>
* 🎞️ [Udemy: CKAD Certified Kubernetes Application Developer Crash Course](https://www.udemy.com/course/ckad-certified-kubernetes-application-developer/)<sup>Blog</sup>

## 💬 Share To Your Network
If this repo has helped you in any way, feel free to share and star !


