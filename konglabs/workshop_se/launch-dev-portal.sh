#!/bin/bash
# stops script on first error
# set -e

cd docker-compose && docker-compose -f workshop_bootstrap_dev_portal.yml up -d

echo "please wait..."
sleep 1s
echo "Kong Enterprise installing..."
sleep 10s

echo "Installing Mocking Plugin"
docker cp temp/kong-plugin-mocking/kong/plugins/mocking/  kong-ent:/usr/local/share/lua/5.1/kong/plugins
docker exec -ti kong-ent /bin/sh -c "KONG_PLUGINS='bundled,mocking' kong reload" && rm -Rf temp

echo "**** Kong-Environment*****"
echo "Kong Manager: $KONG_GUI"