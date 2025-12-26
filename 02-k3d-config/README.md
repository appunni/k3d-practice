# K3d Configuration Files

## Learning Objectives

- Understand the benefits of using configuration files over CLI commands
- Learn K3d config file structure and syntax
- Configure advanced cluster features via YAML
- Version control your cluster configurations

## Why Configuration Files?

### **CLI vs Config Files Comparison**

| Aspect | CLI Commands | Config Files |
|--------|-------------|--------------|
| **Reproducibility** | Hard to reproduce exactly | Exact reproduction |
| **Version Control** | Can't track in Git easily | Perfect for Git |
| **Complexity** | Long, error-prone commands | Clear, structured |
| **Documentation** | Command needs docs | Self-documenting |
| **Sharing** | Copy-paste issues | Easy to share |
| **Team Collaboration** | Inconsistent setups | Everyone uses same config |

### **When to Use Config Files**

- When you need to recreate clusters repeatedly
- When working in a team
- For CI/CD pipelines
- When cluster setup is complex
- For documentation purposes

## Key Configuration Commands

### Creating Clusters from Config Files

```bash
# Create cluster using config file
k3d cluster create --config <config-file>
k3d cluster create --config examples/01-simple-cluster.yaml

# Alternative short form
k3d cluster create -c <config-file>
k3d cluster create -c examples/01-simple-cluster.yaml
```

### Overriding Config Values

```bash
# Create with custom name (overrides config)
k3d cluster create my-cluster --config examples/01-simple-cluster.yaml
```
