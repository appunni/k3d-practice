# Network Configuration Exercise

Learn how k3d network configuration enables or isolates communication between clusters.

## Learning Objectives
- Understand k3d's default network behavior (isolated)
- Configure custom Docker networks in k3d
- Enable multi-cluster communication using shared networks
- Test network connectivity between clusters

## Exercise: Network Isolation vs Shared Network

### Steps (from 02-k3d-config/06-network-config folder):

1. Create a shared Docker network
   ```bash
   docker network create k3d-shared-network
   ```

2. Create all three clusters
   ```bash
   # Default isolated cluster
   k3d cluster create -c cluster-config-1.yaml
   
   # Two clusters on shared network
   k3d cluster create -c cluster-config-2.yaml
   k3d cluster create -c cluster-config-3.yaml
   ```

3. Verify all clusters are running
   ```bash
   k3d cluster list
   kubectl config get-contexts
   ```

4. Test connectivity: shared-cluster1 → shared-cluster2 (should work ✅)
   ```bash
   # Get the Docker IP of shared-cluster2 server node
   CLUSTER2_IP=$(docker inspect k3d-shared-cluster2-server-0 -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
   
   # Test from shared-cluster1 server node
   docker exec k3d-shared-cluster1-server-0 ping -c 3 $CLUSTER2_IP
   ```
   **Result**: ✅ Ping succeeds (clusters on same Docker network can communicate at node level)

5. Test connectivity: default-cluster → shared-cluster1 (should fail ❌)
   ```bash
   # Get the Docker IP of shared-cluster1 server node
   SHARED1_IP=$(docker inspect k3d-shared-cluster1-server-0 -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
   
   # Try to ping from default-cluster
   docker exec k3d-default-cluster-server-0 ping -c 3 $SHARED1_IP || echo "❌ Connection failed - clusters are isolated!"
   ```
   **Result**: ❌ Ping fails (different Docker networks, isolated)

6. Clean up
    ```bash
    k3d cluster delete default-cluster
    k3d cluster delete shared-cluster1
    k3d cluster delete shared-cluster2
    
    docker network rm k3d-shared-network
    ```

## Understanding the Configuration

**Default Network (cluster-config-1.yaml):**
```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: default-cluster
servers: 1
agents: 1
# No network specified - k3d creates isolated network
```
→ Creates: `k3d-default-cluster` network (isolated)

**Custom Shared Network (cluster-config-2.yaml & cluster-config-3.yaml):**
```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: shared-cluster1
servers: 1
agents: 1
network: k3d-shared-network  # ← Key configuration
```
→ Uses: `k3d-shared-network` (shared with other clusters)

**Key Takeaway:**
- **Without `network:`** → Each cluster gets isolated network
- **With `network: <name>`** → Clusters share network and can communicate
- **Important**: Cross-cluster communication uses Docker node IPs, not pod IPs. Each cluster has its own pod network (CNI overlay - Flannel in k3s) that is isolated even when clusters share a Docker network.

## Use Cases

**Isolated Networks (Default):**
- Independent dev/test environments
- Security isolation
- No interference between clusters

**Shared Networks:**
- Multi-cluster testing
- Service mesh scenarios
- Cluster federation
- Distributed system simulation
