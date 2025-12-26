# Node Labels & Taints Exercise

Learn how to control Pod scheduling using Node Labels and Taints in k3d.

## Learning Objectives
- Apply labels and taints to specific nodes via k3d config
- Use `nodeSelector` to schedule Pods to specific nodes
- Use `tolerations` to schedule Pods on tainted nodes

## Exercise: Scheduling with Labels and Taints

### Steps (from 02-k3d-config/08-node-scheduling):

1. Create the cluster:
   ```bash
   k3d cluster create -c cluster-config.yaml
   ```

2. Verify Node Labels:
   ```bash
   kubectl get nodes --show-labels
   # Check for tier=frontend and tier=backend
   ```

3. Verify Node Taints (Server Isolation):
   ```bash
   kubectl describe node k3d-labels-taints-cluster-server-0 | grep Taints
   # Should see: node-role.kubernetes.io/control-plane=true:NoSchedule
   ```

4. Deploy the Frontend Pod (targets `tier=frontend`):
   ```bash
   kubectl apply -f deployments/frontend-pod.yaml
   ```

5. Verify Frontend Pod placement:
   ```bash
   kubectl get pod frontend-app -o wide
   # Should be running on agent-0
   ```

6. Deploy the Maintenance Pod (tolerates control-plane taint):
   ```bash
   kubectl apply -f deployments/maintenance-pod.yaml
   ```

7. Verify Maintenance Pod placement:
   ```bash
   kubectl get pod maintenance-job -o wide
   # Should be running on server-0 (due to toleration)
   ```

8. Cleanup
   ```bash
   k3d cluster delete labels-taints-cluster
   ```

## Understanding the Configuration

**Labels & Taints (cluster-config.yaml):**
```yaml
options:
  k3s:
    nodeLabels:
      - label: tier=frontend
        nodeFilters:
          - agent:0
    extraArgs:
      - arg: "--node-taint=node-role.kubernetes.io/control-plane=true:NoSchedule"
        nodeFilters:
          - server:0
```

**Key Takeaway:**
- **Node Labels**: Key-value pairs attached to nodes. Used with `nodeSelector` or `affinity` to tell Pods where to go.
- **Node Taints**: "Repel" Pods from nodes. Only Pods with a matching `toleration` can schedule there.
- **Use Case**: Tainting the Control Plane (Server) ensures that user applications only run on Worker nodes (Agents), mimicking a production Kubernetes environment.
