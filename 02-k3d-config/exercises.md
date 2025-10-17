# K3d Configuration Exercises

Hands-on exercises to practice working with K3d configuration files.

## Exercise 1: Create Simple Cluster from Config File

### Steps (from 02-k3d-config folder) :
1. Create the cluster using the configuration file
   ```bash
   k3d cluster create --config examples/01-simple-cluster.yaml
   
   # Alternative short form
   k3d cluster create -c examples/01-simple-cluster.yaml
   ```

2. Verify the cluster was created
   ```bash
   k3d cluster list
   kubectl get nodes
   ```

3. Delete cluster
   ```bash
   k3d cluster delete my-first-config-cluster
   ```

4. Verify clusters are gone
   ```bash
   k3d cluster list
   ```

---

## Exercise 2: Create Multi-Node Cluster from Config File

### Steps (from 02-k3d-config folder):
1. Create the multi-node cluster using the configuration file
   ```bash
   k3d cluster create -c examples/02-multi-node-cluster.yaml
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

5. Count the nodes by role
   ```bash
   kubectl get nodes --selector='node-role.kubernetes.io/control-plane'
   kubectl get nodes --selector='!node-role.kubernetes.io/control-plane'
   ```

6. Delete cluster
   ```bash
   k3d cluster delete multi-node-cluster
   ```
