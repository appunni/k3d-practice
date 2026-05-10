# Rolling Updates and Rollbacks

Learn how Kubernetes updates Deployments with zero downtime and how to recover from a bad update.

## Learning Objectives
- Understand how a rolling update works (maxSurge, maxUnavailable)
- Trigger updates by changing the container image
- Monitor a rollout in progress with `kubectl rollout status`
- Inspect rollout history and revision records
- Roll back to a previous revision with `kubectl rollout undo`

## Setup

Create the cluster (from 04-deployments-and-updates/02-rolling-updates-rollbacks):
```bash
k3d cluster create -c cluster-config.yaml
```

Verify the cluster:
```bash
kubectl get nodes
```

## Exercise 1: Triggering a Rolling Update (Imperative)

1. Create a Deployment using an older pinned image:
   ```bash
   kubectl create deployment web --image=nginx:1.24-alpine --replicas=4
   ```

2. Verify all 4 Pods are running and note the current image:
   ```bash
   kubectl get pods -o wide
   kubectl get deploy web -o wide
   ```

3. Update the image to a newer version:
   ```bash
   kubectl set image deployment/web nginx=nginx:1.25-alpine
   ```

4. Watch the rolling update in real time:
   ```bash
   kubectl rollout status deployment/web
   ```
   You will see each Pod replaced one at a time.

5. Verify the new image is running on all Pods:
   ```bash
   kubectl get deploy web -o wide
   kubectl describe deploy web | grep Image
   ```

6. Check the ReplicaSets — the old one is kept with 0 replicas:
   ```bash
   kubectl get replicasets
   ```
   There are now **two** ReplicaSets. The old one is retained to enable rollback.

7. Clean up:
   ```bash
   kubectl delete deployment web
   ```

## Exercise 2: Rollout History and Annotations

1. Create a Deployment:
   ```bash
   kubectl create deployment web --image=nginx:1.24-alpine --replicas=3
   ```

2. Check the rollout history (only revision 1 so far):
   ```bash
   kubectl rollout history deployment/web
   ```
   Notice the `CHANGE-CAUSE` column is `<none>` — you need `--record` or annotations to populate it.

3. Update the image and add a change cause annotation:
   ```bash
   kubectl set image deployment/web nginx=nginx:1.25-alpine
   kubectl annotate deployment/web kubernetes.io/change-cause="upgrade to nginx 1.25"
   ```

4. Update again to a third version:
   ```bash
   kubectl set image deployment/web nginx=nginx:1.26-alpine
   kubectl annotate deployment/web kubernetes.io/change-cause="upgrade to nginx 1.26"
   ```

5. View the full revision history:
   ```bash
   kubectl rollout history deployment/web
   ```
   You should see 3 revisions with their change causes.

6. Inspect a specific revision:
   ```bash
   kubectl rollout history deployment/web --revision=2
   ```

7. Clean up:
   ```bash
   kubectl delete deployment web
   ```

## Exercise 3: Rolling Back a Bad Update

1. Create a Deployment and record the initial state:
   ```bash
   kubectl create deployment web --image=nginx:1.25-alpine --replicas=4
   kubectl annotate deployment/web kubernetes.io/change-cause="initial deploy nginx 1.25"
   ```

2. Verify it is healthy:
   ```bash
   kubectl rollout status deployment/web
   kubectl get pods
   ```

3. Simulate a bad update — deploy a broken image:
   ```bash
   kubectl set image deployment/web nginx=nginx:broken-tag-does-not-exist
   kubectl annotate deployment/web kubernetes.io/change-cause="bad update with broken image"
   ```

4. Watch what happens:
   ```bash
   kubectl rollout status deployment/web
   # Press Ctrl+C after a few seconds
   kubectl get pods
   ```
   Notice some Pods are in `ErrImagePull` or `ImagePullBackOff` — but the old Pods are still running because `maxUnavailable` limits how many are taken down at once.

5. Confirm the Deployment is not fully healthy:
   ```bash
   kubectl get deploy web
   # READY column will show fewer than desired (e.g. 3/4)
   ```

6. Roll back to the previous good revision:
   ```bash
   kubectl rollout undo deployment/web
   ```

7. Verify recovery:
   ```bash
   kubectl rollout status deployment/web
   kubectl get pods
   kubectl get deploy web
   ```
   All 4 Pods are Running again.

8. Check the history — rollback created a new revision:
   ```bash
   kubectl rollout history deployment/web
   ```

9. Clean up:
   ```bash
   kubectl delete deployment web
   ```

## Exercise 4: Declarative Update with the Manifest

1. Apply the manifest (starts at `nginx:1.25-alpine`, 4 replicas, explicit strategy):
   ```bash
   kubectl apply -f manifests/web-deployment.yaml
   kubectl rollout status deployment/web-deployment
   ```

2. Review the rolling update strategy defined in the manifest:
   ```bash
   kubectl describe deploy web-deployment | grep -A5 "Strategy"
   ```

3. Update the image by editing the manifest:
   ```bash
   # Open manifests/web-deployment.yaml and change:
   # image: nginx:1.25-alpine
   # to:
   # image: nginx:1.26-alpine
   ```

4. Apply the updated manifest:
   ```bash
   kubectl apply -f manifests/web-deployment.yaml
   kubectl rollout status deployment/web-deployment
   ```

5. Verify the new image:
   ```bash
   kubectl get deploy web-deployment -o wide
   ```

6. Roll back using undo (works regardless of imperative or declarative):
   ```bash
   kubectl rollout undo deployment/web-deployment
   kubectl rollout status deployment/web-deployment
   kubectl get deploy web-deployment -o wide
   ```

7. Clean up:
   ```bash
   kubectl delete -f manifests/web-deployment.yaml
   ```

## Cleanup

```bash
k3d cluster delete rollout-cluster
```

## Understanding the Concepts

### How a Rolling Update Works

When you update a Deployment's image, Kubernetes does **not** delete all Pods and recreate them. Instead it replaces them gradually, controlled by two fields:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # how many extra Pods can exist above desired count
    maxUnavailable: 1  # how many Pods can be unavailable at once
```

With `replicas: 4`, `maxSurge: 1`, `maxUnavailable: 1`:
- Kubernetes can temporarily have up to **5** Pods (4 + 1 surge)
- At most **1** Pod can be unavailable at any time
- Minimum **3** Pods are always serving traffic during the update

This is what gives you **zero-downtime deploys**.

### The ReplicaSet Revision Trail

Every image change creates a **new ReplicaSet**. The old one is kept at 0 replicas:

```
rs/web-abc123   4 replicas   ← current (new image)
rs/web-def456   0 replicas   ← previous (old image, kept for rollback)
```

`kubectl rollout undo` simply scales the old ReplicaSet back up and scales down the current one.

### Rollout Commands Reference

```bash
# Check rollout progress
kubectl rollout status deployment/<name>

# View revision history
kubectl rollout history deployment/<name>

# Inspect a specific revision
kubectl rollout history deployment/<name> --revision=N

# Roll back to previous revision
kubectl rollout undo deployment/<name>

# Roll back to a specific revision
kubectl rollout undo deployment/<name> --to-revision=N

# Pause a rollout mid-way
kubectl rollout pause deployment/<name>

# Resume a paused rollout
kubectl rollout resume deployment/<name>
```

### Annotating Change Cause

`--record` is deprecated. The correct way to document what changed:

```bash
kubectl annotate deployment/<name> kubernetes.io/change-cause="your message here"
```

Or declare it in the manifest:

```yaml
metadata:
  annotations:
    kubernetes.io/change-cause: "upgrade to nginx 1.26"
```
