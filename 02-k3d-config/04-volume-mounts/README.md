# Volume Mounts Exercise

Learn how to persist data and share files between host and K3d cluster nodes.

## Learning Objectives
- Understand K3d volume mounting concepts
- Learn the difference between node volumes and pod volumes
- Practice sharing data between host and cluster
- Explore persistent storage scenarios

## Exercise: Create Cluster with Volume Mounts

### Steps (from 02-k3d-config/04-volume-mounts folder):

1. Create local directories on host
   ```bash
   mkdir -p /tmp/k3d-data
   mkdir -p /tmp/k3d-config
   echo "Hello from host" > /tmp/k3d-data/host-file.txt
   echo "foo-config=enabled" > /tmp/k3d-config/config.ini
   ```

2. Create the cluster with volume mounts
   ```bash
   k3d cluster create -c cluster-config.yaml
   ```

3. Verify the cluster was created
   ```bash
   k3d cluster list
   kubectl get nodes
   ```

4. Test volume mounts on nodes
   ```bash
   # Check server node
   docker exec k3d-volume-mount-cluster-server-0 ls /data
   docker exec k3d-volume-mount-cluster-server-0 cat /data/host-file.txt
   
   # Check agent node  
   docker exec k3d-volume-mount-cluster-agent-0 ls /data
   docker exec k3d-volume-mount-cluster-agent-0 cat /shared-config/config.ini
   ```

5. Create a pod to test persistent volumes
   ```bash
   kubectl apply -f deployments/volume-test-pod.yaml
   ```

6. Test writing data from pod to host
   ```bash
   kubectl exec volume-test-pod -- sh -c "echo 'Written from pod' > /data/pod-file.txt"
   kubectl exec volume-test-pod -- ls /data
   ```

7. Verify file appears on host
   ```bash
   ls /tmp/k3d-data/
   cat /tmp/k3d-data/pod-file.txt
   ```

8. Test persistence by recreating pod
   ```bash
   kubectl delete pod volume-test-pod
   kubectl apply -f deployments/volume-test-pod.yaml
   kubectl exec volume-test-pod -- cat /data/pod-file.txt
   ```

9. Clean up
   ```bash
   kubectl delete -f deployments/volume-test-pod.yaml
   k3d cluster delete volume-mount-cluster
   ```

## Understanding the Configuration

**Volume Mount Config (cluster-config.yaml):**
```yaml
volumes:
  - volume: /tmp/k3d-data:/data
    nodeFilters:
      - all
  - volume: /tmp/k3d-config:/shared-config
    nodeFilters:
      - server:0
```

**Key Takeaway:**
- `volume: /host/path:/container/path`: Mounts a host directory into the container.
- `nodeFilters: [all]`: Mounts the volume on every node in the cluster.
- `nodeFilters: [server:0]`: Mounts the volume only on the first server node.


## Understanding the Configuration

**Volume mounts in this example:**
- `/tmp/k3d-data:/data` → Available on all nodes (server + agents)
- `/tmp/k3d-config:/shared-config` → Available on specific nodes (server:0, agent:0)

**How it works:**
```
Host filesystem (/tmp/k3d-data)
    ↓ (bind mount)
Container filesystem (/data)
    ↓ (hostPath volume)
Pod filesystem (/data)
```