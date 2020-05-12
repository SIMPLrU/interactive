#!/bin/bash
# stops script on first error
# set -e

cd docker-compose && docker-compose -f workshop_bootstrap_dev_portal.yml up -d

echo "please wait..."
sleep 2s
echo "Kong Enterprise installing..."
sleep 7s

n=0
until [ "$n" -ge 5 ]
do
   http get :8001 2>/dev/null && break # substitute your command here
   echo "just a few more moments ..."
   n=$((n+1))
   sleep 3s
done


echo "Mocking Plugin installing ..."
docker cp temp/kong-plugin-mocking/kong/plugins/mocking/  kong-ent:/usr/local/share/lua/5.1/kong/plugins
docker exec -ti kong-ent /bin/sh -c "KONG_PLUGINS='bundled,mocking' kong reload" && rm -Rf temp

echo "**** Kong-Environment*****"
echo "Kong Manager: $KONG_GUI"