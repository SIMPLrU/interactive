#!/bin/bash
# stops script on first error
# set -e

# Access shell
docker exec -it  kong-ee  /bin/sh

# create and check kong.conf file
cd  /etc/kong/
cp kong.conf.default kong.conf
kong check

# Enable RBAC, ADMIN_GUI_AUTH, ADMIN_GUI_SESSION_CONF
KONG_ENFORCE_RBAC=on \
KONG_ADMIN_GUI_AUTH=basic-auth \
KONG_ADMIN_GUI_SESSION_CONF='{ "secret":"admin_secret", "cookie_secure":false, "storage":"kong", "cookie_name":"kookie", "cookie_samesite":"off" }' \
kong reload kong.conf --vv | grep -e 'admin_gui_session_conf'

# Exit Shell
exit

http get :8001



# ====EXIT script====
exit 2  	# Misuse of shell builtins (according to Bash documentation)
exit 0		# Sucess
exit 1 		# General errors, Miscellaneous errors, such as "divide by zero" and other impermissible operations

docker run -it --net kong-net -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=test -p 8080:8080 -d vietsimplru/keycloak
