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

3. Verify Node Taints:
   ```bash
   kubectl describe node k3d-labels-taints-cluster-agent-1 | grep Taints
   # Should see: dedicated=gpu:NoSchedule
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

6. Deploy the GPU Pod (targets `tier=backend` with toleration):
   ```bash
   kubectl apply -f deployments/gpu-pod.yaml
   ```

7. Verify GPU Pod placement:
   ```bash
   kubectl get pod gpu-job -o wide
   # Should be running on agent-1 (the tainted node)
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
      - arg: "--node-taint=dedicated=gpu:NoSchedule"
        nodeFilters:
          - agent:1
```

**Key Takeaway:**
- **Node Labels**: Key-value pairs attached to nodes. Used with `nodeSelector` or `affinity` to tell Pods where to go.
- **Node Taints**: "Repel" Pods from nodes. Only Pods with a matching `toleration` can schedule there.
- **Use Case**: Taints are perfect for dedicated hardware (GPUs) or isolating specific workloads.
