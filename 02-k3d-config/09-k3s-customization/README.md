# K3s Extra Args Exercise

Learn how to customize the underlying k3s distribution by passing extra arguments, such as disabling default components.

## Learning Objectives
- Pass arguments to the k3s server process via k3d config
- Disable the default Traefik ingress controller
- Verify the absence of disabled components

## Exercise: Disable Default Traefik Ingress

### Steps (from 02-k3d-config/09-k3s-customization):

1. Create the cluster:
   ```bash
   k3d cluster create -c cluster-config.yaml
   ```

2. Verify Traefik is NOT running:
   ```bash
   kubectl get pods -n kube-system
   # You should NOT see any pod named 'traefik-...'
   # You should NOT see any job named 'helm-install-traefik-...'
   ```

3. Verify by creating an Ingress resource:
   ```bash
   kubectl apply -f deployments/test-ingress.yaml
   ```

4. Check the Ingress status:
   ```bash
   kubectl get ingress test-ingress
   ```
   *Result:* The `ADDRESS` column should remain empty because there is no Ingress Controller to assign it an IP.

5. Cleanup
   ```bash
   k3d cluster delete k3s-args-cluster
   ```

## Understanding the Configuration

**Extra Args (cluster-config.yaml):**
```yaml
options:
  k3s:
    extraArgs:
      - arg: "--disable=traefik"
        nodeFilters:
          - server:*
```

**Key Takeaway:**
- `extraArgs`: Allows passing flags directly to the `k3s server` or `k3s agent` process.
- `--disable=traefik`: A standard k3s flag to prevent the installation of the bundled Traefik ingress controller.
- **Use Case**: Essential when you want to install a different Ingress Controller (like Nginx, Istio, or Kong) or keep the cluster minimal.
