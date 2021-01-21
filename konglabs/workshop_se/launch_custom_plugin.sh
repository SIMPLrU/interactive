#!/bin/bash
# stops script on first error
# set -e
systemctl is-active docker.service || systemctl start docker
cd docker-compose && docker-compose -f workshop_bootstrap_custom_plugin.yml up -d


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

# Install Mocking Plugin
echo "Mocking Plugin installing ..."
docker cp temp/kong-plugin-mocking/kong/plugins/mocking/  kong-ee-custom:/usr/local/share/lua/5.1/kong/plugins
docker exec -ti kong-ee-custom /bin/sh -c "KONG_PLUGINS='bundled,mocking' kong reload" && rm -Rf temp
