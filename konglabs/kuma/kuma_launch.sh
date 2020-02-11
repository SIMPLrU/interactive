#!/bin/bash
# stops script on first error
# set -e

# DEPLOY K3S SERVER
nohup k3s server --docker > /dev/null 2>&1 &
    
echo "Installing your Kubernetes cluster...please wait"

sleep 20s

echo "Deploying your cluster ..."
sleep 2s

# Create Alias 
alias kubectl="k3s kubectl"
sleep 5

# Display Cluster Info
kubectl cluster-info

# WAIT FOR SERVICES
echo  "Kubernetes cluster starting ..."

# coredns #? PASSED 
echo "Installing coredns"
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/coredns

echo "coredns is ready"

# metrics-server #? PASSED
echo "Installing metric-server"
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/metrics-server
echo "metrics-server is ready"

# local-path-provisioner #? PASSED

echo "Installing local-path-provisioner"
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/local-path-provisioner
echo "local-path-provisioner is ready"

# traefik #? PASSED
echo "Installing traefik "
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/traefik

echo "traefik is ready"

# helm-install
# svclb-traefik

clear 
# Display Cluster Info
kubectl cluster-info

# Verify Cluster is working
kubectl get pods --all-namespaces
