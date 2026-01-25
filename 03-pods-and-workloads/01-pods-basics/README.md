# Pods Basics

Learn the foundational building block of Kubernetes: the Pod.

## Learning Objectives
- Understand what a Pod is (the atomic unit in Kubernetes)
- Create and manage Pods with kubectl
- Inspect Pods and view logs
- Troubleshoot Pod issues

## Setup

Create the cluster (from 03-pods-and-workloads/01-pods-basics):
```bash
k3d cluster create -c cluster-config.yaml
```

Verify the cluster:
```bash
kubectl get nodes
```

## Exercise 1: Creating Your First Pod

1. Create a simple Pod:
   ```bash
   kubectl run nginx-pod --image=nginx:alpine
   ```

2. Verify the Pod is running:
   ```bash
   kubectl get pods
   kubectl get pods -o wide
   ```

3. Check the Pod details:
   ```bash
   kubectl describe pod nginx-pod
   ```

4. Delete the Pod:
   ```bash
   kubectl delete pod nginx-pod
   ```

## Exercise 2: Interacting with Pods

1. Create a Pod:
   ```bash
   kubectl run nginx-pod --image=nginx:alpine
   ```

2. View Pod logs:
   ```bash
   kubectl logs nginx-pod
   ```

3. Execute commands inside the Pod:
   ```bash
   # List files
   kubectl exec nginx-pod -- ls /usr/share/nginx/html
   
   # Check environment variables
   kubectl exec nginx-pod -- env
   
   # Check running processes
   kubectl exec nginx-pod -- ps aux
   ```

4. Get an interactive shell:
   ```bash
   kubectl exec -it nginx-pod -- sh
   ```
   
   Inside the shell, try:
   ```bash
   ls /etc/nginx
   cat /etc/nginx/nginx.conf
   exit
   ```

5. Delete the Pod:
   ```bash
   kubectl delete pod nginx-pod
   ```

## Exercise 3: Understanding Pod Lifecycle

1. Create a Pod that will fail:
   ```bash
   kubectl run failing-pod --image=nginx:nonexistent-tag
   ```

2. Watch the Pod status:
   ```bash
   kubectl get pods -w
   # Press Ctrl+C to stop watching
   ```

3. Check why it failed:
   ```bash
   kubectl describe pod failing-pod
   kubectl logs failing-pod
   ```

4. Delete the failing Pod:
   ```bash
   kubectl delete pod failing-pod
   ```

5. Create a Pod that completes successfully:
   ```bash
   kubectl run busybox-pod --image=busybox:latest --restart=Never -- echo "Hello Kubernetes"
   ```

6. Check its status:
   ```bash
   kubectl get pods
   kubectl logs busybox-pod
   ```

7. Clean up:
   ```bash
   kubectl delete pod busybox-pod
   ```

## Cleanup

```bash
k3d cluster delete pods-basics-cluster
```

## Understanding the Concepts

### What is a Pod?

A **Pod** is the smallest and simplest unit in Kubernetes. It represents a single instance of a running process in your cluster.

Key characteristics:
- Contains one or more containers (usually just one)
- Containers in a Pod share the same network namespace (same IP)
- Containers can communicate via localhost
- Pods are ephemeral - they can be created, destroyed, and recreated


### Common kubectl Commands

```bash
# Create a Pod
kubectl run <pod-name> --image=<image>

# List Pods
kubectl get pods
kubectl get pods -o wide

# Describe Pod (detailed info)
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>
kubectl logs <pod-name> -f  # Follow logs

# Execute command
kubectl exec <pod-name> -- <command>
kubectl exec -it <pod-name> -- sh  # Interactive shell

# Delete Pod
kubectl delete pod <pod-name>
```

## Key Takeaways

1. **Pods are the fundamental unit** - Everything in Kubernetes builds on this
2. **Create with kubectl run** - Simple: `kubectl run <name> --image=<image>`
3. **Always verify** - Use `kubectl get pods` and `kubectl describe pod`
4. **Troubleshoot with kubectl exec** - Access containers to debug
5. **Watch lifecycle states** - Pods transition: Pending → Running → Succeeded/Failed
6. **Pods are ephemeral** - They can be deleted and recreated anytime
