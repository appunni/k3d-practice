#!/bin/bash

# Setup Verification Script for K3d Prerequisites

echo "Verifying K3d Prerequisites Setup..."
echo "=================================="

# Check Docker
echo "1. Checking Docker..."
docker -v

# Check kubectl
echo ""
echo "2. Checking kubectl..."
kubectl version --client

# Check k3d
echo ""
echo "3. Checking k3d..."
k3d version

echo ""
echo "=================================="
echo "Setup verification complete!"