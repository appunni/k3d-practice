# Registry Configuration Exercise

Learn how to set up and use a local container registry with K3d for faster development workflows.

## Learning Objectives
- Understand the benefits of a local container registry
- Create a K3d cluster with integrated registry
- Push and pull images to/from the local registry
- Deploy applications using local registry images

## Exercise: Create Cluster with Local Registry

### Steps (from 02-k3d-config/05-registry-config folder):

1. Create the cluster with integrated registry
   ```bash
   k3d cluster create -c cluster-config.yaml
   ```

2. Verify the cluster and registry were created
   ```bash
   k3d cluster list
   k3d registry list
   docker ps
   ```

3. Check registry is accessible
   ```bash
   curl localhost:5000/v2/_catalog
   # Should return: {"repositories":[]}
   ```

4. Build a simple test image
   ```bash
   docker build -t localhost:5000/hello-app:v1 -f deployments/Dockerfile .
   ```

5. Push image to local registry
   ```bash
   docker push localhost:5000/hello-app:v1
   ```

6. Verify image is in registry
   ```bash
   curl localhost:5000/v2/_catalog
   ```

7. Deploy the application using the local registry image
   ```bash
   kubectl apply -f deployments/hello-app.yaml
   ```

8. Check pod status
   ```bash
   kubectl get pod hello-app
   ```

9. Check the logs of the pod
   ```bash
   kubectl logs hello-app
   ```

10. Clean up
    ```bash
    kubectl delete -f deployments/hello-app.yaml
    k3d cluster delete registry-cluster
    # Registry is automatically deleted with the cluster
    ```

## Understanding the Configuration

**Registry settings:**
- **Name**: `registry.localhost` (registry container name and DNS name)
- **Host**: `0.0.0.0` (accessible from host machine)
- **Port**: `5000` (standard registry port)

**How it works:**
```
Docker Build → localhost:5000/image:tag
    ↓
Local Registry (registry.localhost)
    ↓
K3d Cluster pulls from registry
    ↓
Pods run with local images
```

## Important: localhost vs registry.localhost

**Two different contexts:**

1. **From your host machine:**
   - Use `localhost:5000` for building and pushing images
   - Example: `docker push localhost:5000/hello-app:v1`

2. **From inside K3d cluster:**
   - Use `registry.localhost:5000` in Kubernetes manifests
   - Example: `image: registry.localhost:5000/hello-app:v1`

**Why?** K3d creates a Docker network and configures DNS so cluster nodes can reach the registry using `registry.localhost`. Your host machine accesses it via `localhost`.

