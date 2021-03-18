#!/bin/bash
# stops script on first error
# set -e
# start docker

export KONG_EE_VERSION=2.3.2.0-centos

systemctl is-active docker.service || systemctl start docker
cd docker-compose && docker-compose -f workshop_bootstrap_rbac.yml up -d


echo "please wait..."
sleep 1s
echo "Kong Enterprise installing..."
sleep 5s

while true
do
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" localhost:8001/status)
    if [ $STATUS_CODE -eq 401 ]; then
	http get :8001 Kong-Admin-Token:kong_admin && echo "OK" 
	break
   else
	echo "Kong not started yet - status: $STATUS_CODE. Please wait"
        sleep 5s
    fi
 done
 