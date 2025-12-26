# Hello K3d

This folder contains your first hands-on experience with K3d clusters.

## Learning Goals

- Create and delete K3d clusters
- Explore cluster information
- List nodes and system pods
- Get familiar with basic K3d operations

## Reference
- **basic-commands.md** - Essential K3d and kubectl commands

## Exercise 1: Create Your First Cluster

### Steps:
1. Create a cluster named "practice-cluster"
   ```bash
   k3d cluster create practice-cluster
   ```

2. Verify the cluster is running
   ```bash
   kubectl cluster-info
   ```

3. Check what nodes are available
   ```bash
   kubectl get nodes
   ```

## Exercise 2: Explore Cluster Information

### Steps:
1. List all K3d clusters
   ```bash
   k3d cluster list
   ```

2. Get detailed cluster information
   ```bash
   k3d cluster get practice-cluster
   ```

3. Check Kubernetes version
   ```bash
   kubectl version
   ```

## Exercise 3: Explore System Pods

### Steps:
1. List all pods in all namespaces
   ```bash
   kubectl get pods -A
   ```

2. Focus on kube-system namespace
   ```bash
   kubectl get pods -n kube-system
   ```

## Exercise 4: Clean Up

### Steps:
1. Delete the cluster
   ```bash
   k3d cluster delete practice-cluster
   ```

2. Verify deletion
   ```bash
   k3d cluster list
   ```
