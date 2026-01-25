# Namespaces

Learn how to organize and isolate Kubernetes resources using Namespaces.

## Learning Objectives
- Understand what Namespaces are and why they matter
- Create and manage Namespaces
- Deploy resources to specific Namespaces
- Query resources across Namespaces

## Setup

Create the cluster (from 03-pods-and-workloads/03-namespaces):
```bash
k3d cluster create -c cluster-config.yaml
```

Verify the cluster:
```bash
kubectl get nodes
```

## Exercise 1: Exploring Default Namespaces

1. List all namespaces in the cluster:
   ```bash
   kubectl get namespaces
   # Or shorthand:
   kubectl get ns
   ```

2. View Pods across all namespaces:
   ```bash
   kubectl get pods --all-namespaces
   # Or shorthand:
   kubectl get pods -A
   ```

3. View Pods in the kube-system namespace:
   ```bash
   kubectl get pods -n kube-system
   ```

4. Describe a namespace:
   ```bash
   kubectl describe namespace kube-system
   ```

## Exercise 2: Creating Namespaces (Imperative)

1. Create a namespace imperatively:
   ```bash
   kubectl create namespace development
   ```

2. Verify the namespace was created:
   ```bash
   kubectl get namespaces
   ```

3. Create another namespace:
   ```bash
   kubectl create namespace production
   ```

4. List namespaces again:
   ```bash
   kubectl get ns
   ```

## Exercise 3: Creating Namespaces (Declarative)

1. Delete the imperative namespaces:
   ```bash
   kubectl delete namespace development
   kubectl delete namespace production
   ```

2. Create namespaces from YAML:
   ```bash
   kubectl apply -f manifests/namespaces.yaml
   ```

3. Verify both namespaces were created:
   ```bash
   kubectl get namespaces
   ```

## Exercise 4: Deploying Pods to Namespaces

1. Create a Pod in the development namespace (imperative):
   ```bash
   kubectl run nginx-dev --image=nginx:alpine -n development
   ```

2. Create a Pod in the production namespace (imperative):
   ```bash
   kubectl run nginx-prod --image=nginx:alpine -n production
   ```

3. List Pods across all namespaces:
   ```bash
   kubectl get pods -A
   ```

4. List Pods in specific namespaces:
   ```bash
   kubectl get pods -n development
   kubectl get pods -n production
   ```

5. Try listing Pods without specifying a namespace:
   ```bash
   kubectl get pods
   # Notice: These Pods won't appear because they're not in the default namespace
   ```

6. Clean up the imperative Pods:
   ```bash
   kubectl delete pod nginx-dev -n development
   kubectl delete pod nginx-prod -n production
   ```

## Cleanup

```bash
k3d cluster delete namespaces-cluster
```

## Understanding the Concepts

### What are Namespaces?

**Namespaces** provide a mechanism for isolating groups of resources within a single cluster. Think of them as virtual clusters within your physical cluster.

**Key characteristics:**
- Names of resources must be unique within a namespace, but not across namespaces
- Namespaces provide scope for Kubernetes names
- Not all objects are in a namespace (nodes, persistentVolumes, etc. are cluster-scoped)
- Deleting a namespace deletes ALL resources within it

**Default namespaces:**
- `default` - Resources with no namespace specified
- `kube-system` - System components
- `kube-public` - Publicly readable resources
- `kube-node-lease` - Node heartbeat information

### Common kubectl Commands for Namespaces

```bash
# List namespaces
kubectl get namespaces
kubectl get ns

# Create namespace
kubectl create namespace <name>

# Delete namespace (deletes ALL resources in it!)
kubectl delete namespace <name>

# View resources in specific namespace
kubectl get pods -n <namespace>

# View resources across all namespaces
kubectl get pods -A
```

## Key Takeaways

1. **Namespaces provide scope** - Same resource names can exist in different namespaces
2. **Default namespaces exist** - `default`, `kube-system`, `kube-public`, `kube-node-lease`
3. **Use -n flag** - Specify namespace for operations or set context default
4. **Imperative creation is fast** - `kubectl create namespace <name>`
5. **Isolation is limited** - Namespaces isolate names/resources, not network traffic
6. **Production pattern** - Separate environments (dev/staging/prod) with namespaces
7. **Query across all** - Use `-A` or `--all-namespaces` to see everything
