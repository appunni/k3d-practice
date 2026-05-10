# Deployments Basics

Learn how Deployments manage Pods at scale and why they replace naked Pods in real clusters.

## Learning Objectives
- Understand what a Deployment is and how it differs from a naked Pod
- Create Deployments imperatively and declaratively
- Understand `selector`, `replicas`, and the Pod template
- Inspect a Deployment and see how it manages ReplicaSets and Pods
- Scale a Deployment up and down

## Setup

Create the cluster (from 04-deployments-and-updates/01-deployments-basics):
```bash
k3d cluster create -c cluster-config.yaml
```

Verify the cluster and nodes:
```bash
kubectl get nodes
```
You should see 1 server + 2 agents — 3 nodes total. Deployments will spread Pods across them.

## Exercise 1: Creating a Deployment (Imperative)

1. Create a Deployment with 3 replicas:
   ```bash
   kubectl create deployment nginx --image=nginx:alpine --replicas=3
   ```

2. Watch the Pods come up:
   ```bash
   kubectl get pods -w
   # Press Ctrl+C when all are Running
   ```

3. List the Deployment:
   ```bash
   kubectl get deployments
   # or shorthand:
   kubectl get deploy
   ```

4. See which nodes the Pods landed on:
   ```bash
   kubectl get pods -o wide
   ```
   Notice Pods are spread across different nodes automatically.

5. List the ReplicaSet that the Deployment created:
   ```bash
   kubectl get replicasets
   # or shorthand:
   kubectl get rs
   ```

6. Check the full ownership chain:
   ```bash
   kubectl describe deployment nginx
   ```
   Look for the `NewReplicaSet` field and the `Events` section.

7. Delete a Pod manually and watch it self-heal:
   ```bash
   # Copy one pod name from: kubectl get pods
   kubectl delete pod <pod-name>

   # Watch the Deployment immediately replace it
   kubectl get pods -w
   # Press Ctrl+C
   ```

8. Clean up:
   ```bash
   kubectl delete deployment nginx
   ```

## Exercise 2: Creating a Deployment (Declarative)

1. Apply the pre-created manifest:
   ```bash
   kubectl apply -f manifests/nginx-deployment.yaml
   ```

2. Verify the Deployment, ReplicaSet, and Pods:
   ```bash
   kubectl get deploy,rs,pods --show-labels
   ```
   Notice the labels on every Pod match the `selector.matchLabels` in the manifest.

3. Inspect the Deployment in detail:
   ```bash
   kubectl describe deploy nginx-deployment
   ```
   Pay attention to:
   - `Selector` — how the Deployment finds its Pods
   - `Replicas` — desired vs ready vs available
   - `StrategyType` — defaults to `RollingUpdate`
   - `Events` — what happened when you applied it

4. View the full Deployment YAML (including fields Kubernetes added):
   ```bash
   kubectl get deploy nginx-deployment -o yaml
   ```

5. Clean up:
   ```bash
   kubectl delete -f manifests/nginx-deployment.yaml
   ```

## Exercise 3: Scaling a Deployment

1. Create a Deployment with 1 replica to start:
   ```bash
   kubectl create deployment nginx --image=nginx:alpine --replicas=1
   ```

2. Verify only 1 Pod is running:
   ```bash
   kubectl get pods -o wide
   ```

3. Scale up to 5 replicas:
   ```bash
   kubectl scale deployment nginx --replicas=5
   ```

4. Watch the new Pods come up:
   ```bash
   kubectl get pods -w
   # Press Ctrl+C when all are Running
   ```

5. Verify Pods spread across nodes:
   ```bash
   kubectl get pods -o wide
   ```

6. Scale down to 2 replicas:
   ```bash
   kubectl scale deployment nginx --replicas=2
   ```

7. Verify Pods were terminated:
   ```bash
   kubectl get pods
   ```

8. Check the Deployment status:
   ```bash
   kubectl get deploy nginx
   ```
   The `READY` column shows `2/2` — desired and available match.

9. Clean up:
   ```bash
   kubectl delete deployment nginx
   ```

## Exercise 4: Generate Deployment YAML with --dry-run

1. Generate a Deployment manifest without applying it:
   ```bash
   kubectl create deployment api \
     --image=nginx:alpine \
     --replicas=3 \
     --dry-run=client -o yaml
   ```

2. Save it to a file:
   ```bash
   kubectl create deployment api \
     --image=nginx:alpine \
     --replicas=3 \
     --dry-run=client -o yaml > manifests/api-deployment.yaml
   ```

3. Open the file and add labels to the metadata section:
   ```yaml
   # Under metadata:, add:
   labels:
     app: api
     tier: backend
     env: dev
   ```

4. Apply and verify:
   ```bash
   kubectl apply -f manifests/api-deployment.yaml
   kubectl get deploy,pods --show-labels
   ```

5. Clean up:
   ```bash
   kubectl delete -f manifests/api-deployment.yaml
   rm manifests/api-deployment.yaml
   ```

## Cleanup

```bash
k3d cluster delete deployments-cluster
```

## Understanding the Concepts

### Deployment vs Naked Pod

| | Naked Pod | Deployment |
|---|---|---|
| **Self-healing** | No — deleted Pod is gone | Yes — replaced automatically |
| **Scaling** | Manual, one at a time | `--replicas=N` |
| **Rolling updates** | Not possible | Built-in |
| **Used in production** | Never | Always |

A naked `kubectl run` pod is useful for **debugging and learning**. Everything in production uses a Deployment.

### The Ownership Chain

```
Deployment
    └── ReplicaSet         (created and owned by the Deployment)
            └── Pod        (created and owned by the ReplicaSet)
            └── Pod
            └── Pod
```

- The **Deployment** manages ReplicaSets. It creates a new ReplicaSet on every image change.
- The **ReplicaSet** maintains the desired Pod count. If a Pod dies, the ReplicaSet creates a replacement.
- **Pods** are created by the ReplicaSet using the `template` defined in the Deployment spec.

### The selector Field

The `selector` is how a Deployment identifies which Pods it owns:

```yaml
spec:
  selector:
    matchLabels:
      app: nginx        # Deployment manages Pods with this label
  template:
    metadata:
      labels:
        app: nginx      # Pods created from this template get this label
```

**The `selector.matchLabels` and `template.metadata.labels` must match.** Kubernetes enforces this — applying a manifest where they differ will fail.

### Deployment YAML Structure

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment        # Name of the Deployment
spec:
  replicas: 3                   # How many Pods to maintain
  selector:
    matchLabels:
      app: nginx                # Which Pods this Deployment owns
  template:                     # Blueprint for each Pod
    metadata:
      labels:
        app: nginx              # Must match selector.matchLabels
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
```

### Key kubectl Commands

```bash
# Create
kubectl create deployment <name> --image=<image> --replicas=N

# Inspect
kubectl get deployments
kubectl get deploy,rs,pods          # see full ownership chain
kubectl describe deploy <name>

# Scale
kubectl scale deployment <name> --replicas=N

# Generate YAML
kubectl create deployment <name> --image=<image> --dry-run=client -o yaml

# Delete
kubectl delete deployment <name>
kubectl delete -f manifests/file.yaml
```
