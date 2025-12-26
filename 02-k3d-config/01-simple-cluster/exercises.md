# Simple Cluster Exercise

Learn the basics of creating a K3d cluster from a configuration file.

## Learning Objectives
- Create first cluster from a configuration file
- Understand basic cluster structure

## Exercise: Create Simple Cluster

### Steps (from 02-k3d-config/01-simple-cluster folder):

1. Create the cluster using the configuration file
   ```bash
   k3d cluster create -c cluster-config.yaml
   ```

2. Verify the cluster was created
   ```bash
   k3d cluster list
   kubectl get nodes
   ```

3. Check cluster information
   ```bash
   kubectl cluster-info
   ```

4. List all nodes with details
   ```bash
   kubectl get nodes -o wide
   ```

5. Check system pods
   ```bash
   kubectl get pods -n kube-system
   ```

6. Delete cluster
   ```bash
   k3d cluster delete my-first-config-cluster
   ```

7. Verify cluster is gone
   ```bash
   k3d cluster list
   ```

## Understanding the Configuration

**Basic Config (cluster-config.yaml):**
```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: my-first-config-cluster
servers: 1
agents: 0
```

**Key Takeaway:**
- `apiVersion` & `kind`: Required fields for k3d config.
- `metadata.name`: Sets the name of the cluster (referenced in `k3d cluster list`).
- `servers: 1`: Creates one control-plane node (master).
- `agents: 0`: Creates zero worker nodes (workloads run on the server node in this case).
