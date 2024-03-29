#!/bin/bash
# stops script on first error
# set -e

export KONG_LICENSE_DATA='{"license":{"version":1,"signature":"f9de2df93d66ca7b8673cd5eb78da09ff2d647e744e994e8bbbe64d8a528e11f9267ae6797af817a265f99c26e2bd8c32cf768fe8aeb83fcc61b26ab4ce7d92a","payload":{"customer":"Labs","license_creation_date":"2021-10-01","product_subscription":"Kong Enterprise Subscription","support_plan":"Platinum","admin_seats":"1","dataplanes":"10","license_expiration_date":"2021-11-30","license_key":"0011K00002G3VTdQAN_a1V1K0000084y9EUAQ"}}}'

systemctl is-active docker.service || systemctl start docker
# launch-dev-portal.sh
cd docker-compose && docker-compose -f workshop_bootstrap_dev_portal_summit.yml up -d

# Wait for containers to load
echo "please wait..."
sleep 2s
echo "Kong Enterprise installing..."
sleep 7s

# Verify Kong Enterprise is installed and started; otherwise wait
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

# Install Mocking Plugin
echo "Mocking Plugin installing ..."
docker cp temp/kong-plugin-mocking/kong/plugins/mocking/  kong-ent:/usr/local/share/lua/5.1/kong/plugins
docker exec -ti kong-ent /bin/sh -c "KONG_PLUGINS='bundled,mocking' kong reload" && rm -Rf temp

# Provide environment parameters
echo "****Kong Environment*****"
echo "Kong Manager: $KONG_GUI"