# !/bin/sh
# stops script on first error
# set -e

############################################################################
# Kubernetes Boostrap Launch Script - Single Node Cluster
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
echo  "please wait..."
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


echo "Kubernetes cluster is ready, make sure all the pods are running"
sleep 1s

# show kube-system pods
kubectl get pods -n kube-system

# Set up environment varables
export PROXY_IP=$(kubectl get -o jsonpath="{.spec.clusterIP}" service -n kong kong-proxy)
curl -i $PROXY_IP


############################################################################
# Kubernetes Boostrap Launch Script - Single Node Cluster
############################################################################



############################################################################
# Deploy Kong Ingress Controller - Database-less
############################################################################

# Deploy Kong Ingress Controller
kubectl apply -f https://bit.ly/kong-ingress-dbless #TODO move to image

clear 
echo "Kong Ingress Controller is launching..."
sleep 5s

echo "Kong Ingress Controller is preparing..."
sleep 2s

# Wait for ingress-kong to start 
kubectl wait --timeout=400s --for=condition=Ready -n kong pods -l app=ingress-kong

# get kong pods
kubectl get pods -n kong

# Get kong services
kubectl get service -n kong

# Export PROXY_IP as variable
export PROXY_IP=$(kubectl get -o jsonpath="{.spec.clusterIP}" service -n kong kong-proxy)
echo $PROXY_IP

clear 
echo "Kong Ingress Controller is finalizing..."
sleep 5s

# Verify
curl -i $PROXY_IP

############################################################################
# Deploy Kong Ingress Controller - Database-less
############################################################################




############################################################################
# Deploy Sample Services
############################################################################

# Deploy Sample Services (kongu)
curl -sL  https://bit.ly/sample-echo-service | kubectl apply -f -
curl -sL  https://bit.ly/sample-httpbin-service | kubectl apply -f -

# Wait for services to deploy
sleep 5s
echo "please wait, sample services deploying..."
kubectl wait --timeout=400s --for=condition=Ready -n default pods -l app=echo
kubectl wait --timeout=400s --for=condition=Ready -n default pods -l app=httpbin
kubectl wait --timeout=400s --for=condition=Ready -n default pods -l app=httpbin-2
echo "sample services deployed..."

# Verify Pods are running
kubectl get pods -n default


############################################################################
# Deploy Sample Services
############################################################################


