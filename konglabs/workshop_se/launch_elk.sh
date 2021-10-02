#!/bin/bash
# stops script on first error
# set -e

export KONG_EE_VERSION=2.3.2.0-centos
export KONG_LICENSE_DATA='{"license":{"version":1,"signature":"f9de2df93d66ca7b8673cd5eb78da09ff2d647e744e994e8bbbe64d8a528e11f9267ae6797af817a265f99c26e2bd8c32cf768fe8aeb83fcc61b26ab4ce7d92a","payload":{"customer":"Labs","license_creation_date":"2021-10-01","product_subscription":"Kong Enterprise Subscription","support_plan":"Platinum","admin_seats":"1","dataplanes":"10","license_expiration_date":"2021-11-30","license_key":"0011K00002G3VTdQAN_a1V1K0000084y9EUAQ"}}}'

systemctl is-active docker.service || systemctl start docker
docker rmi -f 785a9bc72f3
docker rmi -f 91184190279
clear
cd docker-compose && docker-compose -f workshop_bootstrap_elk.yml up -d

echo "please wait..."
sleep 1s
echo "Kong Enterprise installing..."
sleep 5s

while true
do
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" localhost:8001/status)
    if [ $STATUS_CODE -eq 200 ]; then
	http get :8001 && echo "OK" 
	break
    else
	echo "Kong not started yet - status: $STATUS_CODE. Please wait"
        sleep 5s
    fi
done