# Labels and Selectors

Learn how to organize, query, and filter Kubernetes resources using labels and selectors.

## Learning Objectives
- Understand what labels are and why they matter
- Add, update, and remove labels imperatively
- Filter resources using equality-based and set-based selectors
- Define labels declaratively in YAML manifests
- Understand how selectors connect resources (preview of Deployments and Services)

## Setup

Create the cluster (from 03-pods-and-workloads/04-labels-selectors):
```bash
k3d cluster create -c cluster-config.yaml
```

Verify the cluster:
```bash
kubectl get nodes
```

## Exercise 1: Viewing and Adding Labels (Imperative)

1. Create a Pod without any custom labels:
   ```bash
   kubectl run nginx-pod --image=nginx:alpine
   ```

2. View the Pod's labels:
   ```bash
   kubectl get pods --show-labels
   ```
   Notice the `run=nginx-pod` label — kubectl adds it automatically with `kubectl run`.

3. Add a label to the running Pod:
   ```bash
   kubectl label pod nginx-pod env=dev
   ```

4. Add another label:
   ```bash
   kubectl label pod nginx-pod app=frontend
   ```

5. Verify both labels were added:
   ```bash
   kubectl get pods --show-labels
   ```

6. Update an existing label (requires `--overwrite`):
   ```bash
   kubectl label pod nginx-pod env=staging --overwrite
   ```

7. Verify the label changed:
   ```bash
   kubectl get pods --show-labels
   ```

8. Remove a label (append `-` to the key):
   ```bash
   kubectl label pod nginx-pod env-
   ```

9. Verify the label was removed:
   ```bash
   kubectl get pods --show-labels
   ```

10. Clean up:
    ```bash
    kubectl delete pod nginx-pod
    ```

## Exercise 2: Filtering with Label Selectors

1. Create several Pods with different labels:
   ```bash
   kubectl run frontend-dev --image=nginx:alpine --labels="app=frontend,env=dev"
   kubectl run frontend-prod --image=nginx:alpine --labels="app=frontend,env=prod"
   kubectl run backend-dev --image=nginx:alpine --labels="app=backend,env=dev"
   kubectl run backend-prod --image=nginx:alpine --labels="app=backend,env=prod"
   ```

2. List all Pods with labels visible:
   ```bash
   kubectl get pods --show-labels
   ```

3. Filter by a single label (equality-based):
   ```bash
   # Only frontend Pods
   kubectl get pods -l app=frontend

   # Only dev Pods
   kubectl get pods -l env=dev
   ```

4. Filter by multiple labels (AND logic):
   ```bash
   # Only frontend Pods in dev
   kubectl get pods -l app=frontend,env=dev
   ```

5. Exclude by label:
   ```bash
   # All Pods NOT in prod
   kubectl get pods -l env!=prod
   ```

6. Set-based selectors (more expressive):
   ```bash
   # Pods where env is dev OR prod
   kubectl get pods -l 'env in (dev,prod)'

   # Pods where app is NOT cache
   kubectl get pods -l 'app notin (cache)'
   ```

7. Check if a label key exists at all:
   ```bash
   # Pods that have an 'app' label (any value)
   kubectl get pods -l app
   ```

8. Clean up:
   ```bash
   kubectl delete pod frontend-dev frontend-prod backend-dev backend-prod
   ```

## Exercise 3: Declarative Labels in YAML

1. Apply the pre-created manifest with 5 labeled Pods:
   ```bash
   kubectl apply -f manifests/labeled-pods.yaml
   ```

2. Verify all Pods are running with their labels:
   ```bash
   kubectl get pods --show-labels
   ```

3. Practice filtering against the declarative Pods:
   ```bash
   # All dev Pods
   kubectl get pods -l env=dev

   # All Pods in the web tier
   kubectl get pods -l tier=web

   # frontend Pods in prod only
   kubectl get pods -l app=frontend,env=prod

   # All Pods that are NOT in the data tier
   kubectl get pods -l 'tier notin (data)'
   ```

4. View labels in a wider table format:
   ```bash
   kubectl get pods -L app,tier,env
   ```
   The `-L` flag adds label values as dedicated columns — useful when comparing many Pods.

5. Clean up:
   ```bash
   kubectl delete -f manifests/labeled-pods.yaml
   ```

## Exercise 4: Generate Labeled Pod YAML with --dry-run

1. Generate a labeled Pod manifest without creating it:
   ```bash
   kubectl run api-server \
     --image=nginx:alpine \
     --labels="app=api,tier=backend,env=staging" \
     --dry-run=client -o yaml
   ```

2. Save directly to a file:
   ```bash
   kubectl run api-server \
     --image=nginx:alpine \
     --labels="app=api,tier=backend,env=staging" \
     --dry-run=client -o yaml > manifests/api-pod.yaml
   ```

3. Inspect and apply it:
   ```bash
   cat manifests/api-pod.yaml
   kubectl apply -f manifests/api-pod.yaml
   kubectl get pods --show-labels
   ```

4. Clean up:
   ```bash
   kubectl delete -f manifests/api-pod.yaml
   rm manifests/api-pod.yaml
   ```

## Cleanup

```bash
k3d cluster delete labels-cluster
```

## Understanding the Concepts

### What are Labels?

**Labels** are key-value pairs attached to Kubernetes objects. They are metadata — they don't affect the object's behavior directly, but they are the primary mechanism for organizing and selecting resources.

```yaml
metadata:
  labels:
    app: frontend      # what application
    tier: web          # what layer of the stack
    env: dev           # what environment
    version: v1.2.0    # what version
```

**Rules:**
- Keys and values are strings
- Keys can have an optional prefix: `app.kubernetes.io/name: nginx`
- Values max 63 characters, must start/end with alphanumeric

### Label Selectors

Two types of selectors exist:

**Equality-based** (simple key=value matching):
```bash
kubectl get pods -l app=frontend          # equals
kubectl get pods -l env!=prod             # not equals
kubectl get pods -l app=frontend,env=dev  # AND (comma = AND)
```

**Set-based** (more expressive, used in YAML specs):
```bash
kubectl get pods -l 'env in (dev,staging)'    # in set
kubectl get pods -l 'env notin (prod)'        # not in set
kubectl get pods -l app                        # key exists
kubectl get pods -l '!app'                    # key does not exist
```

### Labels vs Annotations

| | Labels | Annotations |
|---|---|---|
| **Purpose** | Selection and organization | Non-identifying metadata |
| **Used by selectors** | Yes | No |
| **Examples** | `app=frontend`, `env=prod` | `description`, `build-url`, `contact` |

```yaml
metadata:
  labels:
    app: frontend          # selectable
  annotations:
    description: "Main web frontend"   # informational only
```

### Why Labels Matter for What Comes Next

Labels are the **glue** between Kubernetes resources. When you create a Deployment or Service, they use `selector` to find their target Pods by label:

```yaml
# A Service finding Pods by label (preview of Section 05)
spec:
  selector:
    app: frontend    # this Service routes to Pods with app=frontend
```

```yaml
# A Deployment managing Pods by label (preview of Section 04)
spec:
  selector:
    matchLabels:
      app: frontend  # this Deployment owns Pods with app=frontend
```

Without labels, Deployments and Services cannot identify which Pods belong to them.

## CKAD Exam Tips

- **`--show-labels`** — always use this when debugging label issues
- **`-L key1,key2`** — adds label values as columns, great for comparing Pods side by side
- **`-l key=value`** — filter flag, works on any resource (`kubectl get svc -l app=frontend`)
- **Comma = AND** — `-l a=x,b=y` means both must match; there is no OR in equality-based selectors
- **Quotes for set-based** — always wrap set-based selectors in quotes: `-l 'env in (dev,prod)'`
- **`kubectl label --overwrite`** — required to change an existing label value; without it you get an error
- **Labels are on any resource** — not just Pods; you can label Nodes, Services, Namespaces, etc.
- **`kubectl get nodes --show-labels`** — useful for understanding node selectors in scheduling (Section 04)
