# Scaling Deployments

Learn how to control the number of running Pod replicas both manually and automatically.

## Learning Objectives
- Scale Deployments up and down imperatively with `kubectl scale`
- Update replica count declaratively by editing the manifest
- Understand what a Horizontal Pod Autoscaler (HPA) is and how it works
- Create and inspect an HPA both imperatively and declaratively

## Setup

Create the cluster (from 04-deployments-and-updates/03-scaling):
```bash
k3d cluster create -c cluster-config.yaml
```

Verify the cluster:
```bash
kubectl get nodes
```
You should see 1 server + 2 agents — 3 nodes total.

## Exercise 1: Manual Scaling (Imperative)

1. Create a Deployment with 2 replicas:
   ```bash
   kubectl create deployment web --image=nginx:alpine --replicas=2
   ```

2. Verify 2 Pods are running and note which nodes they landed on:
   ```bash
   kubectl get pods -o wide
   ```

3. Scale up to 6 replicas:
   ```bash
   kubectl scale deployment web --replicas=6
   ```

4. Watch the new Pods start:
   ```bash
   kubectl get pods -w
   # Press Ctrl+C when all are Running
   ```

5. Verify Pods are spread across all nodes:
   ```bash
   kubectl get pods -o wide
   ```
   Notice Kubernetes distributes Pods across available nodes automatically.

6. Check the Deployment status:
   ```bash
   kubectl get deploy web
   ```
   The `READY` column should show `6/6`.

7. Scale down to 1 replica:
   ```bash
   kubectl scale deployment web --replicas=1
   ```

8. Verify Pods were terminated:
   ```bash
   kubectl get pods
   ```
   Only 1 Pod remains — the others were terminated gracefully.

9. Clean up:
   ```bash
   kubectl delete deployment web
   ```

## Exercise 2: Scaling via the Manifest (Declarative)

1. Apply the pre-created manifest (starts at 2 replicas with resource requests defined):
   ```bash
   kubectl apply -f manifests/web-deployment.yaml
   ```

2. Verify the Deployment and Pods:
   ```bash
   kubectl get deploy web
   kubectl get pods -o wide
   ```

3. Edit the manifest to change `replicas: 2` to `replicas: 5`:
   ```bash
   # Open manifests/web-deployment.yaml and change:
   # replicas: 2
   # to:
   # replicas: 5
   ```

4. Preview what will change before applying:
   ```bash
   kubectl diff -f manifests/web-deployment.yaml
   ```
   The diff shows the `replicas` field changing from 2 to 5.

5. Apply the updated manifest and watch Pods come up:
   ```bash
   kubectl apply -f manifests/web-deployment.yaml
   kubectl get pods -w
   # Press Ctrl+C when all are Running
   ```

6. Scale back down by editing the manifest to `replicas: 2` and re-applying:
   ```bash
   kubectl apply -f manifests/web-deployment.yaml
   kubectl get pods -w
   # Press Ctrl+C
   ```

7. You can also patch the replica count directly without editing the file:
   ```bash
   kubectl patch deployment web --patch '{"spec": {"replicas": 3}}'
   kubectl get deploy web
   ```

8. Clean up:
   ```bash
   kubectl delete -f manifests/web-deployment.yaml
   ```

## Exercise 3: Horizontal Pod Autoscaler (Imperative)

HPA automatically adjusts the replica count based on observed resource metrics.

1. Create a Deployment with resource requests defined (required for CPU-based HPA):
   ```bash
   kubectl apply -f manifests/web-deployment.yaml
   ```

2. Create an HPA targeting 50% average CPU utilization:
   ```bash
   kubectl autoscale deployment web --min=2 --max=8 --cpu=50%
   ```

3. Check the HPA immediately:
   ```bash
   kubectl get hpa
   ```
   The `TARGETS` column will show `<unknown>/50%` — metrics-server needs a moment to collect data.

4. Wait ~30 seconds and check again:
   ```bash
   kubectl get hpa
   ```
   Once data is available, `TARGETS` shows `0%/50%` — current CPU vs target.

5. Inspect the HPA in detail:
   ```bash
   kubectl describe hpa web
   ```
   Pay attention to:
   - `Reference` — which Deployment it controls
   - `Metrics` — the metric type and target value
   - `Min replicas` / `Max replicas` — the scaling bounds
   - `Deployment pods` — current replica count
   - `Events` — any scaling decisions already made

6. View the full HPA YAML (including fields Kubernetes added):
   ```bash
   kubectl get hpa web -o yaml
   ```

7. Generate a dry-run HPA to see the output YAML structure:
   ```bash
   kubectl autoscale deployment web \
     --min=2 --max=8 --cpu=50% \
     --dry-run=client -o yaml
   ```

8. Clean up:
   ```bash
   kubectl delete hpa web
   kubectl delete -f manifests/web-deployment.yaml
   ```

## Exercise 4: HPA via Manifest (Declarative)

1. Apply both the Deployment and HPA manifests:
   ```bash
   kubectl apply -f manifests/web-deployment.yaml
   kubectl apply -f manifests/web-hpa.yaml
   ```

2. Verify both resources are created:
   ```bash
   kubectl get deploy,hpa
   ```

3. Inspect the HPA:
   ```bash
   kubectl describe hpa web-hpa
   ```

4. Confirm the API version in use:
   ```bash
   kubectl get hpa web-hpa -o yaml | grep apiVersion
   ```
   This shows `autoscaling/v2` — the current stable HPA API.

5. Delete the HPA and observe the Deployment is unaffected:
   ```bash
   kubectl delete hpa web-hpa
   kubectl get deploy web
   ```
   Deleting an HPA does **not** delete or scale down the Deployment — it just removes the autoscaling rule. The Deployment keeps whatever replica count it currently has.

6. Re-apply the HPA and observe it re-attaches to the existing Deployment:
   ```bash
   kubectl apply -f manifests/web-hpa.yaml
   kubectl get hpa
   ```

7. Clean up:
   ```bash
   kubectl delete -f manifests/web-hpa.yaml
   kubectl delete -f manifests/web-deployment.yaml
   ```

## Cleanup

```bash
k3d cluster delete scaling-cluster
```

## Understanding the Concepts

### Manual Scaling vs Autoscaling

| | `kubectl scale` | HPA |
|---|---|---|
| **Trigger** | Manual operator action | Automatic based on metrics |
| **Use case** | Known traffic changes, testing | Dynamic / unpredictable load |
| **Requires metrics-server** | No | Yes |
| **Persists if manifest re-applied** | No — overridden by `replicas` field | Yes — until HPA is deleted |

### Declarative Scaling and HPA Conflict

If you have a manifest with `replicas: 2` **and** an HPA controlling the same Deployment, re-applying the manifest will override the current replica count back to 2, fighting the HPA. To avoid this:
- Omit `replicas` from the manifest entirely when an HPA is in use, or
- Use `kubectl apply --server-side` which respects field ownership

### How HPA Works

```
metrics-server
    └── collects CPU/memory from each Pod (every 60s by default, via --metric-resolution)
            └── HPA controller evaluates every 15s (via --horizontal-pod-autoscaler-sync-period)
                    └── compares current average metric vs target
                            └── scales Deployment up or down within min/max bounds
```

The desired replica count is calculated as:

```
desired = ceil( current_replicas × (current_metric / target_metric) )

Example: ceil( 2 × (80% / 50%) ) = ceil(3.2) = 4 replicas
```

### Resource Requests Are Required for HPA

HPA CPU utilization is expressed as a percentage of each Pod's **requested** CPU:

```yaml
resources:
  requests:
    cpu: 100m     # HPA measures usage as % of this value
```

Without `resources.requests.cpu`, the HPA `TARGETS` column stays `<unknown>` and no scaling occurs.

### HPA YAML Structure

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web             # Deployment to control
  minReplicas: 2          # Never scale below this
  maxReplicas: 8          # Never scale above this
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50  # Target 50% average CPU across all Pods
```

### Key kubectl Commands

```bash
# Manual scaling
kubectl scale deployment <name> --replicas=N

# Preview manifest changes before applying
kubectl diff -f manifests/file.yaml

# Patch replica count without editing the file
kubectl patch deployment <name> --patch '{"spec": {"replicas": N}}'

# Create HPA
kubectl autoscale deployment <name> --min=N --max=N --cpu=N%

# Generate HPA YAML
kubectl autoscale deployment <name> --min=N --max=N --cpu=N% --dry-run=client -o yaml

# Inspect HPA
kubectl get hpa
kubectl describe hpa <name>
kubectl get hpa <name> -o yaml

# Delete HPA
kubectl delete hpa <name>
```
