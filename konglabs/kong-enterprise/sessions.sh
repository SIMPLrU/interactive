#!/bin/bash
# stops script on first error
# set -e

KONG_ENFORCE_RBAC=on \
KONG_ADMIN_GUI_AUTH=basic-auth \
KONG_ADMIN_GUI_SESSION_CONF='{ "secret":"admin_secret", "cookie_secure":false, "storage":"kong", "cookie_name":"kookie", "cookie_samesite":"off" }' \
kong reload kong.conf --vv | grep -e 'admin_gui_session_conf' -e 'enforce_rbac' -e 'admin_gui_auth'

# ====EXIT script====
exit 2  	# Misuse of shell builtins (according to Bash documentation)
exit 0		# Sucess
exit 1 		# General errors, Miscellaneous errors, such as "divide by zero" and other impermissible operations
