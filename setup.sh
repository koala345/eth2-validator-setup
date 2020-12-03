#!/bin/bash
#
# usage: setup.sh <hostname> [<username>] (testnet|mainnet)
#
# example:
#  setup.sh testnet servername john
#
#
NETWORK=$1                # Should typically be 'testnet' or 'mainnet' if you followed readme.
HOSTNAME=$2               # Hostname (or IP address) you're deploying validator to
ANSIBLE_USER=${3:-$USER}  # Username. If not specified, will use local username.

if [ "$#" -lt 2 ]; then
    echo "Usage: setup.sh <network> <hostname> [<username>]"
    echo
    exit 1
fi

# This assumes your user requires a password to sudo to root.
# It also assumes you are using RSA keypair authentication. If you are using
# password authentication, add a '-k' argument to the command below.
ansible-playbook -i "${HOSTNAME}," -u "${ANSIBLE_USER}" -K "eth2_${NETWORK}.yml"
