#!/bin/bash
# stops script on first error
# set -e

# DEPLOY K3S SERVER
nohup k3s server --docker > /dev/null 2>&1 &
    
echo "Installing your kubernetes cluster...please wait"

sleep 20s

echo "Deploying your cluster ..."
echo 2s 

# Create Alias 
alias kubectl="k3s kubectl"
sleep 5

# Display Cluster Info
kubectl cluster-info

# WAIT FOR SERVICES
echo  "Kubernetes cluster starting ..."

# coredns #? PASSED 
echo "installing coredns"
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/coredns

echo "coredns is ready"

# metrics-server #? PASSED
echo "installing metric-server"
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/metrics-server
echo "metrics-server is ready"

# local-path-provisioner #? PASSED

echo "installing local-path-provisioner"
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/local-path-provisioner
echo "local-path-provisioner is ready"

# traefik #? PASSED
echo "installing traefik "
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/traefik

echo "traefik is ready"

# helm-install
# svclb-traefik

clear 
# Display Cluster Info
kubectl cluster-info

# Verify Cluster is working
kubectl get pods --all-namespaces
