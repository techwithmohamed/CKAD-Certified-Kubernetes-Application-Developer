[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

# ☸️  Certified Kubernetes Application Developer (CKAD) Exam Guide - V1.33 (2025)

<p align="center">
  <img src="assets/ckad.png" alt="CKAD EXAM 2025">
</p>

> This guide is part of our blog [How to Pass Certified Kubernetes Application Developer (CKAD) 2025 ](https://techwithmohamed.com/ckad-exam-study-guide/).

## Hit the Star! :star:
> If you are using this repo for guidance, please hit the star. Thanks A lot !

The [Certified Kubernetes Application Developer (CKAD) certification](https://www.cncf.io/certification/ckad/) exam certifies that candidates can design, build and deploy cloud-native applications for Kubernetes.

## CKAD Exam Details

| **CKAD Exam Details**                     | **Information**                                                                                     |
|-------------------------------------------|-----------------------------------------------------------------------------------------------------|
| **Exam Type**                             | Performance based ( NO MCQ )                                                                                            |
| **Exam Duration**                         | 2 hours                                                                                            |
| **Pass Percentage**                       | 66%                                                                                                |
| **CKAD Exam Kubernetes Version**          | Kubernetes v1.33                                                                                |
| **CKAD Validity**                         | 2 Years  |
| **Exam Cost**                            | $445 USD        |


## CKAD Exam Syllabus (Updated Kubernetes 1.33)

| **Topic**                                 | **Concepts**                                                                                                                                                       | **Weightage** |
|-------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| [**Application Design and Build - 20%**](#application-design-and-build-20)          | 1. Define, build, and modify container images<br>2. Understand Jobs and CronJobs<br>3. Understand multi-container Pod design patterns (e.g., sidecar, init, others)<br>4. Utilize persistent and ephemeral volumes | 20%          |
| [**Application Environment, Configuration, and Security - 25%**](#application-environment-configuration-and-security-25) | 1. Discover and use resources that extend Kubernetes (CRD)<br>2. Understand authentication, authorization, and admission control<br>3. Understand and define resource requirements, limits, and quotas<br>4. Understand ConfigMaps<br>5. Create & consume Secrets<br>6. Understand ServiceAccounts<br>7. Understand SecurityContexts | 25%          |
| [**Services & Networking - 20%**](#services-and-networking-20)                | 1. Understand API deprecations<br>2. Implement probes and health checks<br>3. Use provided tools to monitor Kubernetes applications<br>4. Utilize container logs<br>5. Debugging in Kubernetes | 20%          |
| [**Application Deployment - 20%**](#application-deployment-20)              | 1. Use Kubernetes primitives to implement common deployment strategies (e.g., blue/green or canary)<br>2. Understand Deployments and perform rolling updates<br>3. Use Helm package manager to deploy existing packages | 20%          |
| [**Application Observability and Maintenance - 15%**](#application-observability-and-maintenance-15) | 1. Understand API deprecations<br>2. Implement probes and health checks<br>3. Use provided tools to monitor Kubernetes applications<br>4. Utilize container logs<br>5. Debugging in Kubernetes | 15%          |


## Application Design and Build (20%)

The first domain in the CKAD exam is **Application Design and Build**, comprising 20% of the exam. Below are the key topics explained with `kubectl` examples:

### 1. Define, Build, and Modify Container Images
Building and customizing container images is essential for deploying applications in Kubernetes.

#### Example:
**Create a Dockerfile:**
```Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

**Build and push the image:**
```bash
docker build -t <your-dockerhub-username>/custom-nginx:latest .
docker push <your-dockerhub-username>/custom-nginx:latest
```

**Deploy the image in Kubernetes:**
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
        image: <your-dockerhub-username>/custom-nginx:latest
```
```bash
kubectl apply -f deployment.yaml
```

- [Learn more about building images](https://kubernetes.io/docs/concepts/containers/images/)

### 2. Choose and Use the Right Workload Resource
Kubernetes provides various workload resources like Deployment, DaemonSet, and CronJob for different use cases.

#### Example:
**Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web-container
        image: nginx
```
```bash
kubectl apply -f deployment.yaml
```

**CronJob:**
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

- [Learn more about workloads](https://kubernetes.io/docs/concepts/workloads/)

### 3. Understand Multi-Container Pod Design Patterns
Multi-container Pods enable closely related containers to work together, using patterns like **sidecar**, **init container**, etc.

#### Example:
**Sidecar Container Pattern:**
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

- [Learn more about Pod design patterns](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)

### 4. Utilize Persistent and Ephemeral Volumes
Persistent volumes retain data across Pod restarts, while ephemeral volumes are temporary.

#### Example:
**Persistent Volume:**
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

**Ephemeral Volume:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-ephemeral
spec:
  containers:
  - name: app-container
    image: nginx
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```
```bash
kubectl apply -f pod-ephemeral.yaml
```

- [Learn more about persistent and ephemeral volumes](https://kubernetes.io/docs/concepts/storage/)

---

### Resources to Prepare
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [CKAD Exam Tips](https://kubernetes.io/docs/certifications/)


## Application Environment, Configuration, and Security (25%)

This domain constitutes 25% of the CKAD Exam. Below are the key topics explained with `kubectl` examples:

### 1. Discover and Use Resources that Extend Kubernetes (CRD, Operators)
Custom Resource Definitions (CRDs) and Operators extend Kubernetes functionality by defining and managing custom resources.

#### Example:
**Create a CRD:**
```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.example.com
spec:
  group: example.com
  names:
    kind: Widget
    listKind: WidgetList
    plural: widgets
    singular: widget
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

- [Learn more about CRDs](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/)

### 2. Understand Authentication, Authorization, and Admission Control
Authentication identifies users, authorization controls access, and admission control manages resource configurations.

#### Example:
**View authentication configuration:**
```bash
kubectl describe configmap -n kube-system extension-apiserver-authentication
```

**Create a Role and RoleBinding:**
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
```bash
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml
```

- [Learn more about RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

### 3. Understand Requests, Limits, and Quotas
Requests and limits define resource usage for containers, while quotas control resource usage at the namespace level.

#### Example:
**Set resource requests and limits for a Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: busybox
    image: busybox
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```
```bash
kubectl apply -f pod.yaml
```

**Set a Resource Quota:**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: default
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: "2Gi"
    limits.cpu: "8"
    limits.memory: "4Gi"
```
```bash
kubectl apply -f resource-quota.yaml
```

- [Learn more about resource quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

### 4. Understand ConfigMaps
ConfigMaps store configuration data for applications.

#### Example:
**Create a ConfigMap:**
```bash
kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_DEBUG=false
```

**Consume ConfigMap in a Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo
spec:
  containers:
  - name: app-container
    image: busybox
    env:
    - name: APP_ENV
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_ENV
    - name: APP_DEBUG
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_DEBUG
```
```bash
kubectl apply -f pod.yaml
```

- [Learn more about ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)

### 5. Define Resource Requirements
Setting resource requests and limits ensures efficient resource usage.

- Refer to **Section 3: Requests and Limits** for examples.

### 6. Create and Consume Secrets
Secrets store sensitive data like passwords, tokens, and keys.

#### Example:
**Create a Secret:**
```bash
kubectl create secret generic db-credentials --from-literal=username=admin --from-literal=password=secret123
```

**Consume Secret in a Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-demo
spec:
  containers:
  - name: app-container
    image: busybox
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
```
```bash
kubectl apply -f pod.yaml
```

- [Learn more about Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

### 7. Understand ServiceAccounts
ServiceAccounts provide identity for processes running in Pods.

#### Example:
**Create a ServiceAccount:**
```bash
kubectl create serviceaccount my-serviceaccount
```

**Use a ServiceAccount in a Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sa-demo
spec:
  serviceAccountName: my-serviceaccount
  containers:
  - name: app-container
    image: busybox
```
```bash
kubectl apply -f pod.yaml
```

- [Learn more about ServiceAccounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

### 8. Understand Application Security (SecurityContexts, Capabilities, etc.)
SecurityContexts define security settings for Pods and containers.

#### Example:
**Set SecurityContext for a Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: app-container
    image: busybox
    command: [ "sh", "-c", "echo Hello Kubernetes! && sleep 3600" ]
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
```
```bash
kubectl apply -f securitycontext.yaml
```

- [Learn more about SecurityContexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)

---

### Resources to Prepare
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [CKAD Exam Tips](https://kubernetes.io/docs/certifications/)


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


