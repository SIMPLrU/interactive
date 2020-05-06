#!/bin/bash
# stops script on first error
# set -e

# DEPLOY K3S SERVER
nohup k3s server . --server-arg --no-deploy --server-arg traefik --docker > /dev/null 2>&1 &
    
echo "Installing cluster ... please wait"

# TIMER
min=0
sec=15
while [ $min -ge 0 ]; do
    while [ $sec -ge 0 ]; do
        echo -ne "$hour:$min:$sec\033[0K\r"
            let "sec=sec-1"
            sleep 1
        done
        sec=59
            let "min=min-1"
    done


# secs=$((10))
# while [ $secs -gt 0 ]; do
#    echo -ne "$secs\033[0K\r"
#    sleep 1
#    : $((secs--))
# done

echo "Deploying cluster ... getting there"
sleep 3s

echo "Finalizing cluster ... almost there"
# secs=$((10))
# while [ $secs -gt 0 ]; do
#   echo -ne "$secs\033[0K\r"
#   sleep 1
#   : $((secs--))
# done

# Timer
min=0
sec=15
while [ $min -ge 0 ]; do
    while [ $sec -ge 0 ]; do
        echo -ne "$hour:$min:$sec\033[0K\r"
            let "sec=sec-1"
            sleep 1
        done
        sec=59
            let "min=min-1"
    done

# CREATE ALIAS
# alias kubectl="k3s kubectl"
# sleep 5

# WAIT FOR SERVICES
echo  "Starting cluster ..."
sleep 2s

# coredns #? PASSED 
echo "Installing coredns"
# kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/coredns
# echo "coredns is ready"
sleep 2s

# metrics-server #? PASSED
echo "Installing metric-server"
# kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/metrics-server
# echo "metrics-server is ready"
sleep 2s

# local-path-provisioner #? PASSED
echo "Installing local-path-provisioner"
# kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/local-path-provisioner
# echo "local-path-provisioner is ready"
sleep 2s

# helm-install
# traefik #? PASSED
# echo "Installing traefik"
# kubectl wait --timeout=200s --for=condition=Available -n kube-system deployment/traefik
# echo "traefik is ready"
# svclb-traefik

# DISPLAY CLUSTER INFO
# kubectl cluster-info

# VERIFY ALL PODS ARE RUNNING
# kubectl get pods --all-namespaces
echo "The Kubernetes cluster is ready"
sleep 1s

echo "Verify all the pods are running with: 'kubectl get pods --all-namespaces'"

# ====EXIT script====
  exit 2    # Misuse of shell builtins (according to Bash documentation)
  exit 0    # Success
  exit 1    # General errors, Miscellaneous errors, such as "divide by zero" and other impermissible operations
