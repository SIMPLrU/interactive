#!/bin/bash
# stops script on first error
# set -e
systemctl is-active docker.service || systemctl start docker
rm -rf servroot/pids/nginx.pid

mkdir -p ~/.local/bin
# export variables
export KONG_VERSION=2.1.3.1
export POSTGRES=9.6
export PATH=~/.local/bin/:$PATH

# set symlink
ln -s $(realpath kong-pongo/pongo_kjg.sh) ~/.local/bin/pongo

# run Pongo
cd kong-plugin
pongo run


