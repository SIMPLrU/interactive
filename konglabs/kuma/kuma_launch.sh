# !/bin/sh
# stops script on first error
# set -e

# DEPLOY K3S SERVER
nohup k3s server --docker > /dev/null 2>&1 &
    
echo "installing your kubernetes cluster...please wait"

sleep 20s

# Display Cluster Info
kubectl cluster-info

sleep 3s

# Create Alias 
alias kubectl="k3s kubectl"

# WAIT FOR SERVICES

# coredns #? PASSED 
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/coredns

echo "coredns is ready"

# metrics-server #? PASSED
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/metrics-server

echo "metrics-server is ready"

# local-path-provisioner #? PASSED
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/local-path-provisioner

echo "local-path-provisioner"

# traefik #? PASSED
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/traefik

echo "traefik is ready"

# helm-install
# svclb-traefik


# Display Cluster Info
kubectl cluster-info

# Verify Cluster is working
kubectl get pods --all-namespaces
