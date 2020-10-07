#!/bin/bash
# stops script on first error
# set -e

cd docker-compose
docker-compose -f workshop_bootstrap_summit_ee.yml up -d


echo "please wait..."
sleep 1s
echo "Kong installing..."
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