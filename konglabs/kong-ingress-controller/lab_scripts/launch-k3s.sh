#!/bin/bash
# stops script on first error
# set -e

# DEPLOY K3S SERVER
nohup k3s server . --server-arg --no-deploy --server-arg traefik --docker > /dev/null 2>&1 &
    
echo "Installing cluster ... please wait"
sleep 20s

echo "Deploying cluster ..."
sleep 2s

# CREATE ALIAS
# alias kubectl="k3s kubectl"
# sleep 5

# WAIT FOR SERVICES
echo  "Starting cluster ..."

# coredns #? PASSED 
echo "Installing coredns"
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/coredns
echo "coredns is ready"

# metrics-server #? PASSED
echo "Installing metric-server"
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/metrics-server
echo "metrics-server is ready"

clear

# local-path-provisioner #? PASSED
echo "Installing local-path-provisioner"
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/local-path-provisioner
echo "local-path-provisioner is ready"

# helm-install
# traefik #? PASSED
# echo "Installing traefik"
# kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/traefik
# echo "traefik is ready"
# svclb-traefik


echo "Finalizing cluster ..."
sleep 10s

# DISPLAY CLUSTER INFO
kubectl cluster-info

# VERIFY ALL PODS ARE RUNNING
kubectl get pods --all-namespaces

echo "Make sure all the pods are running"

