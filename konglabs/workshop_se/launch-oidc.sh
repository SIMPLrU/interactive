#!/bin/bash
# stops script on first error
# set -e

cd docker-compose
docker-compose -f workshop_bootstrap_oidc.yml up -d

echo "please wait..."
sleep 1s
echo "Kong and Keycloak installing..."
sleep 5s




