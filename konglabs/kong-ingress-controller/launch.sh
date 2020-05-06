# !/bin/sh
# stops script on first error
# set -e

############################################################################
# Kubernetes Boostrap Launch Script - Single Node Cluster
# Helm and Tiller bootstrap
#? PASSED
############################################################################

# Initilize K8s with a customized token
kubeadm init --token=032386.0a9dd2cc9d7f6cc1 --apiserver-advertise-address $(hostname -i)
mkdir -p $HOME/.kube

# cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# Apply weave networking
kubectl apply -n kube-system -f \
"https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 |tr -d '\n')"

# Allow master to also be a worker (e.g. single node cluster)
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl get pods -n kube-system

# export master node ip address #TODO - move to onboot
export MASTER_IP=$(ip -f inet -o addr show eth0|cut -d\  -f 7 | cut -d/ -f 1)

# Worker node join cluster
kubeadm join --discovery-token-unsafe-skip-ca-verification --token=032386.0a9dd2cc9d7f6cc1 $MASTER_IP:6443
clear

echo  "Kubernetes cluster starting ..."

# coredns
kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/coredns

echo "coredns is ready"

# kube-proxy
kubectl wait --timeout=200s --for=condition=Ready -n kube-system pods -l k8s-app=kube-proxy

echo "kube-proxy is ready"

# weave-net
kubectl wait --timeout=200s --for=condition=Ready -n kube-system pods -l name=weave-net

echo "weave-net is ready"

echo "please wait..."
sleep 45s

# kube-apiserver-node1
kubectl wait --timeout=400s --for=condition=Ready -n kube-system pods -l component=kube-apiserver

echo "kube-apiserver is ready"
# kube-controller-manager-node1
kubectl wait --timeout=400s --for=condition=Ready -n kube-system pods -l component=kube-controller-manager

echo "controller-manager is ready"

# etcd-node1
kubectl wait --timeout=400s --for=condition=Ready -n kube-system pods -l component=etcd

echo "etcd is ready"

# kube-scheduler-node1
kubectl wait --timeout=400s --for=condition=Ready -n kube-system pods -l component=kube-scheduler

echo "kube-scheduler is ready"


# Initialize Helm 
helm init
kubectl --namespace kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller-cluster-rule \
--clusterrole=cluster-admin --serviceaccount=kube-system:tiller

kubectl --namespace kube-system patch deploy tiller-deploy \
-p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' 

echo "Tiller deployed"


# Create mounts 
mkdir /mnt/pv{1,2,3}

# Create PVC 
kubectl create -f  https://raw.githubusercontent.com/SIMPLrU/interactive/master/konglabs/kong-ingress-controller/manifests/pvc.yaml

clear 

echo "finalizing cluster..."
sleep 5s
# kubectl wait --timeout=400s --for=condition=Ready -n kube-system pods -l app=helm

# show kube-system pods
kubectl get pods -n kube-system

echo "Kubernetes cluster is ready, make sure all the pods are running"
