# Multi-Node Cluster Exercise

Learn about high availability and multi-node cluster configurations.

## Learning Objectives
- Create a multi-node cluster with multiple servers and agents
- Understand node roles (control-plane vs worker)
- Practice node exploration and filtering

## Exercise: Create Multi-Node Cluster

### Steps (from 02-k3d-config/02-multi-node-cluster folder):

1. Create the multi-node cluster
   ```bash
   k3d cluster create -c cluster-config.yaml
   ```

2. Verify the cluster was created
   ```bash
   k3d cluster list
   kubectl get nodes
   ```

3. Check node roles and details
   ```bash
   kubectl get nodes -o wide
   kubectl get nodes --show-labels
   ```

4. Explore the cluster
   ```bash
   kubectl cluster-info
   kubectl get pods -A
   ```

5. Count nodes by role
   ```bash
   kubectl get nodes --selector='node-role.kubernetes.io/control-plane'
   kubectl get nodes --selector='!node-role.kubernetes.io/control-plane'
   ```

6. Check which node kubectl is connecting to
   ```bash
   kubectl config current-context
   kubectl cluster-info
   ```

7. Delete cluster
   ```bash
   k3d cluster delete multi-node-cluster
   ```
