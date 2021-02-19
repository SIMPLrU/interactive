#!/bin/bash
# stops script on first error
# set -e

###########################################################################
# DEPLOY KONG FOR KUBERNETES
############################################################################

kubectl create namespace kong
kubectl create secret generic kong-enterprise-license --from-file=license=./license.json -n kong
kubectl apply -f demokong-enterprise-0.10.yaml