#!/bin/bash
# stops script on first error
# set -e

###########################################################################
# DEPLOY KONG FOR KUBERNETES
############################################################################

export KONG_EE_VERSION=2.0.4.1-alpine
export KIC_VERSION=1.1

kubectl create namespace kong
kubectl create secret generic kong-enterprise-license --from-file=license=./license.json -n kong
kubectl apply -f demokong-enterprise-0.10.yaml