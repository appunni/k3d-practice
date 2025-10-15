# K3d Practice Exercises

Hands-on exercises to practice cluster operations with K3d.

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

3. Get more details about system pods
   ```bash
   kubectl get pods -n kube-system -o wide
   ```

## Exercise 4: Multiple Clusters

### Steps:
1. Create a second cluster
   ```bash
   k3d cluster create test-cluster
   ```

2. List all clusters
   ```bash
   k3d cluster list
   ```

3. Check current context
   ```bash
   kubectl config current-context
   ```

4. List contexts
   ```bash
   kubectl config get-contexts
   ```

## Exercise 5: Cleanup

### Steps:
1. Delete the test cluster
   ```bash
   k3d cluster delete test-cluster
   ```

2. Verify it's gone
   ```bash
   k3d cluster list
   ```
