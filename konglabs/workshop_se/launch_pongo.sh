#!/bin/bash
# stops script on first error
# set -e

mkdir -p ~/.local/bin
export PATH=~/.local/bin/:$PATH
ln -s $(realpath kong-pongo/pongo.sh) ~/.local/bin/pongo

