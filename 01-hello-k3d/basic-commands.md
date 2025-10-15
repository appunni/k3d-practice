# Basic K3d Commands

Essential commands for working with K3d clusters.

## Cluster Management

### Create a cluster
```bash
k3d cluster create <cluster-name>
k3d cluster create my-cluster
```

### List clusters
```bash
k3d cluster list
```

### Delete a cluster
```bash
k3d cluster delete <cluster-name>
k3d cluster delete my-cluster
```

### Get cluster info
```bash
k3d cluster get <cluster-name>
```

### Start/Stop clusters
```bash
k3d cluster start <cluster-name>
k3d cluster stop <cluster-name>
```

## Kubectl Commands for Cluster Exploration

### Cluster information
```bash
kubectl cluster-info
kubectl version
```

### Node operations
```bash
kubectl get nodes
kubectl get nodes -o wide
kubectl describe node <node-name>
```

### System pods
```bash
kubectl get pods -A
kubectl get pods -n kube-system
kubectl get pods -n kube-system -o wide
```

### Namespaces
```bash
kubectl get namespaces
kubectl get ns
```

### General resource viewing
```bash
kubectl get all
kubectl get all -A
kubectl get all -n <namespace>
```