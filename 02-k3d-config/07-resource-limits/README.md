# Resource Limits Exercise

Learn how to configure resource limits (memory/CPU) for k3d nodes to simulate constrained environments.

## Learning Objectives
- Configure resource limits for k3d nodes
- Verify limits using Docker commands
- Understand the difference between node limits and Kubernetes pod limits

## Exercise: Configure and Verify Resource Limits

### Steps (from 02-k3d-config/07-resource-limits):

1. Create the cluster:
   ```bash
   k3d cluster create -c cluster-config.yaml
   ```

2. Verify the cluster is running:
   ```bash
   k3d cluster list
   kubectl get nodes
   ```

3. Verify memory limit of the server node (should be 512m):
   ```bash
   docker inspect k3d-resource-limits-cluster-server-0 --format '{{.HostConfig.Memory}}'
   ```
   *Note: The output is in bytes. 512MB = 512 * 1024 * 1024 = 536870912 bytes.*

4. Verify memory limit of an agent node (should be 256m):
   ```bash
   docker inspect k3d-resource-limits-cluster-agent-0 --format '{{.HostConfig.Memory}}'
   ```
   *Note: 256MB = 256 * 1024 * 1024 = 268435456 bytes.*

5. (Optional) Verify that Kubernetes sees the resource limits:
   ```bash
   kubectl describe node k3d-resource-limits-cluster-agent-0 | grep -A 5 Capacity
   ```
   You should see `memory` capacity close to the limit (minus some overhead).

### Expected Results
- Cluster creates successfully.
- Docker inspect shows the configured memory limits in bytes.
- `kubectl get nodes` shows all nodes ready.

## Understanding the Configuration

**Resource Limits (cluster-config.yaml):**
```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: resource-limits-cluster
servers: 1
agents: 2
options:
  runtime:
    serversMemory: "512m"  # ← Limits memory for server nodes
    agentsMemory: "256m"   # ← Limits memory for agent nodes
```

**Key Takeaway:**
- `serversMemory`: Sets the Docker memory limit for server containers (control plane).
- `agentsMemory`: Sets the Docker memory limit for agent containers (workers).
- These limits are applied to the **Docker container**, simulating a physical machine with that amount of RAM.
- Kubernetes (k3s) inside the container detects this limit and adjusts its node capacity accordingly.

## Cleanup
```bash
k3d cluster delete resource-limits-cluster
```
