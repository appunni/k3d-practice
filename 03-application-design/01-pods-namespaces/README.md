# Pods and Namespaces Exercise

Learn the foundational building blocks of Kubernetes: Pods and Namespaces.

## Learning Objectives
- Understand what a Pod is (the atomic unit in Kubernetes)
- Create and manage Pods using both imperative and declarative approaches
- Understand Namespaces for organizing and isolating resources
- Query resources across different namespaces

## Setup

Create the cluster (from 03-application-design/01-pods-namespaces):
```bash
k3d cluster create -c cluster-config.yaml
```

## Exercise 1: Creating Your First Pod

### Imperative Approach

1. Create a simple Pod using kubectl run:
   ```bash
   kubectl run nginx-pod --image=nginx:alpine
   ```

2. Verify the Pod is running:
   ```bash
   kubectl get pods
   kubectl get pods -o wide
   ```

3. Delete the imperative Pod:
   ```bash
   kubectl delete pod nginx-pod
   ```

### Declarative Approach

4. Create a Pod from YAML:
   ```bash
   kubectl apply -f manifests/simple-pod.yaml
   ```

5. Verify the Pod is running:
   ```bash
   kubectl get pods
   kubectl describe pod nginx-pod
   ```

## Exercise 2: Basic Pod Commands

1. Create an nginx Pod imperatively:
   ```bash
   kubectl run nginx-pod --image=nginx:alpine --port=80
   ```

2. View detailed Pod information:
   ```bash
   kubectl describe pod nginx-pod
   ```

3. Check Pod logs:
   ```bash
   kubectl logs nginx-pod
   ```

4. Execute commands inside the Pod:
   ```bash
   # List files in nginx directory
   kubectl exec nginx-pod -- ls /usr/share/nginx/html
   
   # Check environment variables
   kubectl exec nginx-pod -- env
   
   # Check nginx process
   kubectl exec nginx-pod -- ps aux
   ```

5. Get an interactive shell:
   ```bash
   kubectl exec -it nginx-pod -- sh
   # Inside the shell, try:
   # - ls /etc/nginx
   # - cat /etc/nginx/nginx.conf
   # - exit
   ```

6. View Pod resource usage (if metrics-server is available):
   ```bash
   kubectl top pod nginx-pod
   # Note: This may not work in basic k3d setup without metrics-server
   ```

## Exercise 3: Working with Namespaces

### Imperative Approach

1. Create namespaces:
   ```bash
   kubectl create namespace development
   kubectl create namespace production
   ```

2. List all namespaces:
   ```bash
   kubectl get namespaces
   # Or shorthand:
   kubectl get ns
   ```

### Declarative Approach

3. Delete the imperative namespaces:
   ```bash
   kubectl delete namespace development
   kubectl delete namespace production
   ```

4. Create namespaces from YAML:
   ```bash
   kubectl apply -f manifests/namespaces.yaml
   ```

## Exercise 4: Isolating Resources with Namespaces

1. Deploy Pods with the same name in different namespaces:
   ```bash
   kubectl apply -f manifests/namespaced-pods.yaml
   ```

2. View Pods across all namespaces:
   ```bash
   kubectl get pods --all-namespaces
   # Or shorthand:
   kubectl get pods -A
   ```

3. View Pods in a specific namespace:
   ```bash
   kubectl get pods -n development
   kubectl get pods -n production
   ```

4. Compare the environment variables in each Pod:
   ```bash
   kubectl exec -n development app-pod -- env | grep ENVIRONMENT
   kubectl exec -n production app-pod -- env | grep ENVIRONMENT
   ```

## Cleanup

```bash
k3d cluster delete pods-demo-cluster
```

## Understanding the Concepts

### Imperative vs Declarative

Kubernetes supports two approaches for managing resources:

**Imperative** - Tell Kubernetes what to do:
- Commands: `kubectl run`, `kubectl create`, `kubectl expose`, `kubectl edit`
- Direct actions: "create this pod", "delete that service"
- Fast for experimentation and debugging
- Useful for exam scenarios with time constraints
- No history of changes (command disappears after execution)

**Declarative** - Tell Kubernetes what you want:
- Define desired state in YAML manifests
- Apply changes with `kubectl apply -f manifests/`
- Kubernetes reconciles current state to match desired state
- Version control friendly (track changes in Git)
- Self-documenting and reproducible across environments
- Production best practice

**When to use each:**
- Imperative: Learning, debugging, quick tests, certification exams
- Declarative: Production deployments, team collaboration, CI/CD pipelines

### Understanding kubectl run Command

The `kubectl run` command syntax follows this pattern:
```bash
kubectl run <pod-name> --image=<image> [options] -- [command] [args]
```

**The double dash (`--`)**: Separates kubectl options from container commands
- Everything before `--` is interpreted by kubectl
- Everything after `--` is passed to the container as the command

**Example breakdown:**
```bash
kubectl run busybox-pod --image=busybox:latest --command -- sleep 3600
```
- `busybox-pod`: Name of the Pod to create
- `--image=busybox:latest`: Container image to use
- `--command`: Flag telling kubectl that a custom command follows
- `--`: Separator between kubectl flags and container command
- `sleep 3600`: Command to run inside the container (keeps it alive for 1 hour)

**Why is this needed?**
- Busybox default behavior: Runs a shell and exits immediately
- Without `sleep`, the Pod would complete and enter `CrashLoopBackOff`
- The `sleep 3600` keeps the container running so you can practice kubectl commands

**Tip:**
Use `kubectl run --help` to see all available options and examples. This is useful for discovering flags, command patterns, and advanced usage as you practice.

### Pod Manifest (simple-pod.yaml)
```yaml
apiVersion: v1
kind: Pod
metadata:
   name: nginx-pod
spec:
   containers:
   - name: nginx
      image: nginx:alpine
```

**Key Concepts:**
- **Pod**: The smallest deployable unit in Kubernetes. It wraps one or more containers.
- **metadata.name**: Unique identifier for the Pod within its namespace.
- **spec.containers**: List of containers running in the Pod (usually just one).
- **image**: The container image to run (pulled from Docker Hub by default).

### Namespace Manifest (namespaces.yaml)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
```

**Key Concepts:**
- **Namespace**: A virtual cluster for organizing resources. Provides scope for names.
- **Use Cases**: Separate environments (dev/prod), multi-tenancy, resource quotas.
- **Default Namespaces**: `default`, `kube-system`, `kube-public`, `kube-node-lease`.

**Why Namespaces Matter:**
- You can have two Pods with the same name (`app-pod`) in different namespaces without conflict.
- Namespaces enable setting resource limits and access controls per environment.

## Tips
- Practice creating resources imperatively without looking at docs
- Know the shorthand: `kubectl run`, `kubectl create ns`, `-n` flag
- Use `kubectl get pods -A` to quickly find resources across namespaces
- Remember: `--dry-run=client -o yaml` to generate YAML templates
