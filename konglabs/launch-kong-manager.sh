#!/bin/bash
# stops script on first error
# set -e

cd $HOME/.kong
docker load -i postgres96.tar
rm postgres96.tar
clear

docker network create kong-net

echo "Installing Database"
sleep 1s
docker run -d --name kong-ee-database --net kong-net -p 5432:5432 -e "POSTGRES_USER=kong" -e "POSTGRES_DB=kong" postgres:9.6
sleep 1s
# export KONG_LICENSE_DATA='{"license":{"signature":"XX5e3fb08d34940f4ff9f60cb4afc3ca8a4f4dcabd3c3cebff3e6dedba2349df2f9c2bd9aee564cb2a229967884003b612f87216a9edbe2cd8d11dbf4c70a3ddf3XX","payload":{"customer":"ABC Partner Company","license_creation_date":"2019-05-30","product_subscription":"Kong Enterprise Edition","admin_seats":"5","support_plan":"None","license_expiration_date":"2019-12-22","license_key":"00141000017OHUFAA4_a1V1K000006vGtjUAE"},"version":1}}'

echo "Bootstrapping Database"
sleep 8s
docker run --rm --link kong-ee-database:kong-ee-database --net kong-net  \
   -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-ee-database" \
   -e "KONG_CASSANDRA_CONTACT_POINTS=kong-ee-database" \
   -e "KONG_LICENSE_DATA=$KONG_LICENSE_DATA" \
   -e "KONG_PASSWORD=kong_admin" \
   kong-ee kong migrations bootstrap

echo "Installing Kong Enterprise"
sleep 5s
docker run -d --name kong-ee --link kong-ee-database:kong-ee-database --net kong-net \
  -e "KONG_DATABASE=postgres" \
  -e "KONG_PG_HOST=kong-ee-database" \
  -e "KONG_CASSANDRA_CONTACT_POINTS=kong-ee-database" \
  -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
  -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
  -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_LISTEN=0.0.0.0:8001" \
  -e "KONG_PORTAL=on" \
  -e "KONG_LICENSE_DATA=$KONG_LICENSE_DATA" \
  -e "KONG_PROXY_LISTEN=0.0.0.0:8000, 0.0.0.0:8443 ssl" \
  -e "KONG_ADMIN_GUI_LISTEN=0.0.0.0:8002" \
  -e "KONG_PORTAL_GUI_LISTEN=0.0.0.0:8003" \
  -e "KONG_VITALS=on" \
  -p 8000:8000 \
  -p 8443:8443 \
  -p 8001:8001 \
  -p 8444:8444 \
  -p 8002:8002 \
  -p 8445:8445 \
  -p 8003:8003 \
  -p 8004:8004 \
  -e "KONG_PORTAL_GUI_HOST=$KONG_PORTAL_GUI_HOST" \
  -e "KONG_PORTAL_AUTH=basic-auth" \
  -e "KONG_ADMIN_APPROVED_EMAIL=false" \
  -e "KONG_ADMIN_GUI_URL=$KONG_GUI" \
  -e "KONG_PROXY_URL=$KONG_8000" \
  -e "KONG_ADMIN_API_URI= $KONG_8001" \
  -e "KONG_PORTAL_API_URL=$KONG_PORTAL_API_URL" \
  -v /var/run/docker.sock:/var/run/docker.sock kong-ee

echo "Verifying Install..."
sleep 3s
cd $HOME
sleep 3s
echo "Kong Enterprise Installed"

echo "Enable Kong Manager for Basic-Auth

docker cp ~/KONG/konglabs/sessions.sh kong-ee:/sessions.sh
docker exec -it kong-ee /bin/sh "/sessions.sh"

echo "Environment is ready" 



# ====EXIT script====
exit 2  	# Misuse of shell builtins (according to Bash documentation)
exit 0		# Sucess
exit 1 		# General errors, Miscellaneous errors, such as "divide by zero" and other impermissible operations

docker run -it --net kong-net -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=test -p 8080:8080 -d vietsimplru/keycloak
