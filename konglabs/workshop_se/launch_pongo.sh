#!/bin/bash
# stops script on first error
# set -e

mkdir -p ~/.local/bin
export KONG_VERSION=2.1.3.1
export POSTGRES=9.6
export PATH=~/.local/bin/:$PATH
ln -s $(realpath kong-pongo/pongo.sh) ~/.local/bin/pongo

