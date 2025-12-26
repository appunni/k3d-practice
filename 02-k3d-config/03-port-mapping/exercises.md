# Port Mapping Exercise

Learn how to expose Kubernetes services to the host machine using port mapping.

## Learning Objectives
- Understand K3d port mapping configuration
- Learn the difference between loadbalancer and direct node mapping
- Practice exposing services on different ports
- Test external access to cluster services

## Exercise: Create Cluster with Port Mapping

### Steps (from 02-k3d-config/03-port-mapping folder):

1. Create the cluster with port mappings
   ```bash
   k3d cluster create -c cluster-config.yaml
   ```

2. Verify the cluster and port mappings
   ```bash
   k3d cluster list
   kubectl get nodes
   ```

3. Check what ports are exposed
   ```bash
   docker ps
   ```

4. Deploy and test all three networking approaches

   ```bash
   # Approach 1: Ingress (port 8080:80)

   # Deploy nginx with Ingress routing
   kubectl apply -f deployments/nginx-ingress.yaml
     
   # Check Ingress (Traefik is available by default in k3s)
   kubectl get ingress
   
   # Test access via Traefik
   curl localhost:8080
   ```

   ```bash
   # Approach 2: LoadBalancer (port 9090:9090)

   # Deploy nginx with LoadBalancer service
   kubectl apply -f deployments/nginx-loadbalancer.yaml
   
   # Check LoadBalancer service (servicelb/klipper-lb available by default in k3s)
   kubectl get services
   
   # Test direct LoadBalancer access
   curl localhost:9090
   ```

   ```bash
   # Approach 3: NodePort (port 9000:30000)

   # Deploy nginx with NodePort service
   kubectl apply -f deployments/nginx-nodeport.yaml
      
   # Check NodePort service
   kubectl get services
   
   # Test NodePort access via server:0
   curl localhost:9000
   ```

5. Clean up deployments
   ```bash
   kubectl delete -f deployments/nginx-ingress.yaml
   kubectl delete -f deployments/nginx-loadbalancer.yaml
   kubectl delete -f deployments/nginx-nodeport.yaml
   ```

8. Delete cluster
    ```bash
    k3d cluster delete port-mapping-cluster
    ```

## Understanding the Configuration

**Port Mapping Config (cluster-config.yaml):**
```yaml
ports:
  - port: 8080:80
    nodeFilters:
      - loadbalancer
  - port: 9000:30000
    nodeFilters:
      - server:0
```

**Key Takeaway:**
- `port: 8080:80`: Maps host port 8080 to container port 80.
- `nodeFilters: [loadbalancer]`: Applies the mapping to the k3d loadbalancer (Traefik ingress).
- `nodeFilters: [server:0]`: Applies the mapping directly to the first server node (useful for NodePort services).
