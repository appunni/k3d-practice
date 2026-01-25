# Imperative vs Declarative and YAML Generation

Learn the difference between imperative and declarative approaches, and master generating Kubernetes YAML manifests.

## Learning Objectives
- Understand the difference between imperative and declarative approaches
- Generate YAML manifests using `--dry-run=client -o yaml`
- Edit and modify Kubernetes resources
- Export existing resources to YAML

## Setup

Create the cluster (from 03-pods-and-workloads/02-imperative-declarative):
```bash
k3d cluster create -c cluster-config.yaml
```

Verify the cluster:
```bash
kubectl get nodes
```

## Exercise 1: Imperative Commands

1. Create a Pod imperatively:
   ```bash
   kubectl run nginx --image=nginx:alpine
   ```

2. Verify it's running:
   ```bash
   kubectl get pods
   ```

3. Try to create another Pod with the same name:
   ```bash
   kubectl run nginx --image=nginx:alpine
   # This will fail - resource already exists!
   ```

4. Clean up:
   ```bash
   kubectl delete pod nginx
   ```

## Exercise 2: Declarative Approach

1. Apply the pre-created manifest:
   ```bash
   kubectl apply -f manifests/simple-pod.yaml
   ```

2. Verify the Pod is running:
   ```bash
   kubectl get pods
   ```

3. Try applying again:
   ```bash
   kubectl apply -f manifests/simple-pod.yaml
   # This is idempotent - no error, just "unchanged"
   ```

4. Modify the manifest file (change image from nginx:alpine to nginx:latest):
   ```bash
   # Edit manifests/simple-pod.yaml and change:
   # image: nginx:alpine
   # to:
   # image: nginx:latest
   ```

5. Apply the updated manifest:
   ```bash
   kubectl apply -f manifests/simple-pod.yaml
   ```

6. Verify the image changed:
   ```bash
   kubectl describe pod nginx
   ```

7. Revert the changes (change back to nginx:alpine) and clean up:
   ```bash
   # Edit manifests/simple-pod.yaml back to nginx:alpine
   kubectl delete -f manifests/simple-pod.yaml
   ```

## Exercise 3: Generating YAML with Dry Run

1. Generate Pod YAML without creating it:
   ```bash
   kubectl run redis --image=redis:alpine --dry-run=client -o yaml
   ```

2. Save to a file:
   ```bash
   kubectl run redis --image=redis:alpine --dry-run=client -o yaml > redis-pod.yaml
   ```

3. Create the Pod from generated YAML:
   ```bash
   kubectl apply -f redis-pod.yaml
   ```

4. Verify:
   ```bash
   kubectl get pods
   ```

5. Clean up:
   ```bash
   kubectl delete -f redis-pod.yaml
   rm redis-pod.yaml
   ```

## Exercise 4: Exporting Existing Resources

1. Create a Pod imperatively:
   ```bash
   kubectl run nginx --image=nginx:alpine --port=80
   ```

2. Export the running Pod to YAML:
   ```bash
   kubectl get pod nginx -o yaml
   ```

3. Save to a file (with managed fields removed):
   ```bash
   kubectl get pod nginx -o yaml > exported-pod.yaml
   ```

4. Delete the original Pod:
   ```bash
   kubectl delete pod nginx
   ```

5. Recreate from exported YAML:
   ```bash
   kubectl apply -f exported-pod.yaml
   # This works even with extra fields - they're ignored
   ```

6. Clean up:
   ```bash
   kubectl delete -f exported-pod.yaml
   rm exported-pod.yaml
   ```

## Exercise 5: Editing Resources

1. Create a Pod:
   ```bash
   kubectl run nginx --image=nginx:alpine
   ```

2. Edit the Pod directly (opens in editor):
   ```bash
   kubectl edit pod nginx
   # Try changing the image from nginx:alpine to nginx:latest
   # Save and quit - notice it may fail for some fields
   ```

3. Verify the change:
   ```bash
   kubectl describe pod nginx
   ```

4. Clean up:
   ```bash
   kubectl delete pod nginx
   ```

## Cleanup

```bash
k3d cluster delete kubectl-practice-cluster
```

## Understanding the Concepts

### Imperative vs Declarative

**Imperative Approach:**
- Commands tell Kubernetes what to do: "create this", "delete that"
- Examples: `kubectl run`, `kubectl create`, `kubectl delete`, `kubectl edit`
- Pros: Fast, interactive, good for learning and debugging
- Cons: No history, hard to reproduce, not version-controllable

**Declarative Approach:**
- Manifests tell Kubernetes what you want (desired state)
- Command: `kubectl apply -f <file>`
- Kubernetes reconciles current state to match desired state
- Pros: Version control, reproducible, idempotent, self-documenting
- Cons: More verbose initially

### The --dry-run Flag

The `--dry-run` flag simulates the operation without actually executing it:

```bash
kubectl run nginx --image=nginx:alpine --dry-run=client -o yaml
```

**Two modes:**
- `--dry-run=client`: Validates locally (doesn't contact API server)
- `--dry-run=server`: Validates on server (contacts API server but doesn't persist)

**Common use with -o yaml:**
- Generates YAML manifests without creating resources
- Perfect for learning the structure
- Quick way to create templates

### kubectl apply vs create vs replace

**kubectl create:**
```bash
kubectl create -f pod.yaml
# Creates resource
# Fails if resource already exists
```

**kubectl apply:**
```bash
kubectl apply -f pod.yaml
# Creates if doesn't exist
# Updates if exists (declarative management)
# Idempotent - can run multiple times safely
```

**kubectl replace:**
```bash
kubectl replace -f pod.yaml
# Replaces existing resource
# Fails if resource doesn't exist
# Use --force to delete and recreate
```

### Output Formats

```bash
# YAML format (most common for editing)
kubectl get pod nginx -o yaml

# JSON format (good for parsing/scripting)
kubectl get pod nginx -o json

# Wide format (more columns)
kubectl get pods -o wide

# JSONPath (extract specific fields)
kubectl get pod nginx -o jsonpath='{.spec.containers[0].image}'
```

### Generating YAML Templates

**Basic Pod:**
```bash
kubectl run nginx --image=nginx:alpine --dry-run=client -o yaml
```

### Editing Running Resources

**kubectl edit:**
- Opens resource in your default editor
- Changes take effect immediately on save
- Some fields cannot be changed (immutable)

**kubectl patch:**
- Surgically update specific fields
- Good for automation/scripts

**kubectl replace:**
- Replaces entire resource
- Use `--force` to delete and recreate

**Best practice:**
- Edit YAML files, then `kubectl apply`
- Keep YAML in version control
- Avoid `kubectl edit` in production

## Key Takeaways

1. **Imperative is fast** - Good for learning and quick tests
2. **Declarative is production** - Version control, reproducibility, team collaboration
3. **Use dry-run** - Generate YAML templates: `--dry-run=client -o yaml`
4. **kubectl apply is idempotent** - Can run multiple times safely
5. **Export with care** - Use `kubectl get -o yaml` but clean up runtime fields
6. **Edit workflow** - Modify files, then apply (not kubectl edit)
7. **Learn both approaches** - They complement each other
