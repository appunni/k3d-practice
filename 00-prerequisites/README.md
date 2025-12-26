# Prerequisites

This folder contains everything needed to set up K3d on Mac Apple Silicon.

## Installation Guide - Mac Apple Silicon

This guide covers the installation of K3d and its prerequisites on Mac Apple Silicon machines.

### 1. Install Homebrew (if not already installed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Docker Desktop
```bash
brew install --cask docker
```

### 3. Install kubectl

```bash
brew install kubectl
```

### 4. Install k3d
```bash
brew install k3d
```

## Verification

Run the verification script to check your setup:
```bash
./setup-verification.sh
```

## References

- [Homebrew Installation](https://brew.sh/)
- [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
- [kubectl Installation](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#install-with-homebrew-on-macos)
- [K3d Installation](https://k3d.io/v5.8.3/#other-installers)
