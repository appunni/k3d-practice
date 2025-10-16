# K3d Configuration Files

## Learning Objectives

- Understand the benefits of using configuration files over CLI commands
- Learn K3d config file structure and syntax
- Create reusable cluster templates
- Configure advanced cluster features via YAML
- Version control your cluster configurations

## Why Configuration Files?

### **CLI vs Config Files Comparison**

| Aspect | CLI Commands | Config Files |
|--------|-------------|--------------|
| **Reproducibility** | ❌ Hard to reproduce exactly | ✅ Exact reproduction |
| **Version Control** | ❌ Can't track in Git easily | ✅ Perfect for Git |
| **Complexity** | ❌ Long, error-prone commands | ✅ Clear, structured |
| **Documentation** | ❌ Command needs docs | ✅ Self-documenting |
| **Sharing** | ❌ Copy-paste issues | ✅ Easy to share |
| **Team Collaboration** | ❌ Inconsistent setups | ✅ Everyone uses same config |

### **When to Use Config Files**

- When you need to recreate clusters repeatedly
- When working in a team
- For CI/CD pipelines
- When cluster setup is complex
- For documentation purposes