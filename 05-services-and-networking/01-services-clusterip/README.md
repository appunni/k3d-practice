# Services: ClusterIP

Learn how Kubernetes Services provide stable network identities for Pods and enable reliable pod-to-pod communication inside the cluster.

## Learning Objectives
- Understand why Services are needed (Pods have ephemeral IPs)
- Create a ClusterIP Service imperatively and declaratively
- Understand `selector`, `port`, and `targetPort`
- Use DNS-based service discovery inside the cluster
- Inspect Service endpoints and see them update as Pods scale

## Setup

Create the cluster (from 05-services-and-networking/01-services-clusterip):
```bash
k3d cluster create -c cluster-config.yaml
```

Verify the cluster and nodes:
```bash
kubectl get nodes
```
You should see 1 server + 2 agents — 3 nodes total.

## Exercise 1: The Problem ClusterIP Solves

Before creating a Service, observe the problem it solves.

1. Create two Pods:
   ```bash
   kubectl run pod-a --image=nginx:alpine
   kubectl run pod-b --image=curlimages/curl:latest -- sleep 3600
   ```

2. Get pod-a's IP address:
   ```bash
   kubectl get pod pod-a -o wide
   ```
   Note the IP address shown in the `IP` column.

3. Curl pod-a directly from pod-b using its Pod IP:
   ```bash
   # Replace <POD_A_IP> with the IP from the previous step
   kubectl exec pod-b -- curl -s http://<POD_A_IP>
   ```
   This works — but now delete and recreate pod-a:

4. Delete and recreate pod-a, then check its IP again:
   ```bash
   kubectl delete pod pod-a
   kubectl run pod-a --image=nginx:alpine
   kubectl get pod pod-a -o wide
   ```
   The IP has changed. Any hardcoded IP reference is now broken. This is the problem Services solve.

5. Clean up:
   ```bash
   kubectl delete pod pod-a pod-b
   ```

## Exercise 2: Creating a ClusterIP Service (Imperative)

1. Create a backend Deployment:
   ```bash
   kubectl create deployment backend --image=nginx:alpine --replicas=3
   ```

2. Wait for all Pods to be Running:
   ```bash
   kubectl get pods -w
   # Press Ctrl+C when all 3 are Running
   ```

3. Expose the Deployment as a ClusterIP Service:
   ```bash
   kubectl expose deployment backend --name=backend-service --port=80 --target-port=80
   ```

4. Inspect the Service:
   ```bash
   kubectl get service backend-service
   ```
   Notice the `TYPE` is `ClusterIP` and it has a stable `CLUSTER-IP`. This IP will not change even if Pods are replaced.

5. Describe the Service to see its endpoints (the actual Pod IPs behind it):
   ```bash
   kubectl describe service backend-service
   ```
   Look at the `Endpoints` field — it lists the IPs of all 3 backend Pods.

6. Launch a temporary client Pod to test connectivity:
   ```bash
   kubectl run curl-test \
     --image=curlimages/curl:latest \
     --rm -it --restart=Never \
     -- curl -s http://backend-service
   ```
   You should see nginx's default HTML page returned. The `curl-test` Pod resolved `backend-service` via DNS — no IP needed.

7. Test with the full DNS name (FQDN):
   ```bash
   kubectl run curl-test \
     --image=curlimages/curl:latest \
     --rm -it --restart=Never \
     -- curl -s http://backend-service.default.svc.cluster.local
   ```
   Both forms work. The short name works because the client is in the same `default` namespace.

8. Clean up:
   ```bash
   kubectl delete deployment backend
   kubectl delete service backend-service
   ```

## Exercise 3: Creating a ClusterIP Service (Declarative)

1. Apply the backend Deployment and Service manifests:
   ```bash
   kubectl apply -f manifests/backend-deployment.yaml
   kubectl apply -f manifests/backend-service.yaml
   ```

2. Verify both resources are created:
   ```bash
   kubectl get deployment,service
   ```

3. Apply the client Pod manifest:
   ```bash
   kubectl apply -f manifests/client-pod.yaml
   ```

4. Wait for the client Pod to be Running:
   ```bash
   kubectl get pod client -w
   # Press Ctrl+C when Running
   ```

5. Exec into the client Pod and test the Service using its short DNS name:
   ```bash
   kubectl exec client -- curl -s http://backend-service
   ```

6. Test using the FQDN:
   ```bash
   kubectl exec client -- curl -s http://backend-service.default.svc.cluster.local
   ```

7. View the Service YAML (including fields Kubernetes added):
   ```bash
   kubectl get service backend-service -o yaml
   ```
   Notice `clusterIP` has been auto-assigned.

## Exercise 4: Services and Endpoints

Services dynamically track their backing Pods via Endpoints.

1. List the current Endpoints object:
   ```bash
   kubectl get endpoints backend-service
   ```
   You should see 3 IP:port pairs — one per backend Pod.

2. Scale the backend Deployment down to 1 replica and watch Endpoints update:
   ```bash
   kubectl scale deployment backend --replicas=1
   kubectl get endpoints backend-service
   ```
   Only 1 IP:port remains.

3. Scale back up to 5 and watch:
   ```bash
   kubectl scale deployment backend --replicas=5
   kubectl get endpoints backend-service -w
   # Press Ctrl+C once 5 endpoints appear
   ```

4. Delete a backend Pod manually and watch the Endpoint list self-heal:
   ```bash
   # Copy one pod name from: kubectl get pods -l app=backend
   kubectl delete pod <pod-name>
   kubectl get endpoints backend-service -w
   # Press Ctrl+C
   ```
   The Deployment replaces the deleted Pod and the Endpoint is restored automatically.

5. Clean up:
   ```bash
   kubectl delete -f manifests/backend-deployment.yaml
   kubectl delete -f manifests/backend-service.yaml
   kubectl delete -f manifests/client-pod.yaml
   ```

## Understanding the Concepts

### Why Services Exist

Every Pod gets its own IP address — but Pods are ephemeral. They can be deleted, rescheduled, or replaced by rolling updates, and each time they receive a **new IP**. Any component that hardcodes a Pod IP breaks as soon as that Pod is replaced.

A **Service** solves this by providing a **stable virtual IP** (the `clusterIP`) and a **stable DNS name**. Clients always connect to the Service; the Service forwards traffic to whichever Pods are currently healthy.

### ClusterIP: Internal-Only Access

`ClusterIP` is the **default** Service type. It creates a virtual IP that is only reachable **within the cluster**. It is intentionally not accessible from outside the cluster — that is what NodePort and LoadBalancer are for (covered in the next exercise).

```
                   ┌──────────────────────────────┐
                   │          Cluster             │
                   │                              │
  client-pod ─────►│  backend-service (ClusterIP) │────► Pod 1
                   │        10.96.x.x:80          │────► Pod 2
                   │                              │────► Pod 3
                   └──────────────────────────────┘
```

### Service Selector and Endpoints

The Service uses a **label selector** to find its target Pods:

```yaml
spec:
  selector:
    app: backend   # match all Pods with this label
```

Kubernetes continuously watches for Pods matching the selector and maintains an **Endpoints** object with their current IPs. When a Pod is added, removed, or becomes unready, the Endpoints object is updated automatically.

### port vs targetPort

| Field | Meaning |
|---|---|
| `port` | The port clients use to reach the Service |
| `targetPort` | The port the container is actually listening on |

These are often the same (both `80`), but they can differ. For example, a Java app listening on `8080` can be exposed on `port: 80` with `targetPort: 8080`.

### DNS-Based Service Discovery

K3s includes CoreDNS by default. Every Service gets a DNS record in the format:

```
<service-name>.<namespace>.svc.cluster.local
```

Within the **same namespace**, the short form `<service-name>` also resolves correctly because CoreDNS appends the cluster domain as a search suffix. This is why `curl http://backend-service` works from the `default` namespace without the full FQDN.

## Cleanup

```bash
k3d cluster delete services-cluster
```
