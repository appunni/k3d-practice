# Basic K3d Configuration Commands

Essential commands for working with K3d configuration files.

## Creating Clusters from Config Files

### Create cluster using config file
```bash
k3d cluster create --config <config-file>
k3d cluster create --config examples/01-simple-cluster.yaml

# Alternative short form
k3d cluster create -c <config-file>
k3d cluster create -c examples/01-simple-cluster.yaml
```

### Create with custom name (overrides config)
```bash
k3d cluster create my-cluster --config examples/01-simple-cluster.yaml
```