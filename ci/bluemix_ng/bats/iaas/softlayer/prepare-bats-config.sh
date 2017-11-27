#!/bin/bash

set -e -x

state_path() { bosh-cli int director-state/director.yml --path="$1" ; }
creds_path() { bosh-cli int director-state/director-creds.yml --path="$1" ; }

cat > bats-config/bats.env <<EOF
export BOSH_ENVIRONMENT="$( state_path /instance_groups/name=bosh/networks/name=default/static_ips/0 2>/dev/null )"
export BOSH_CLIENT="admin"
export BOSH_CLIENT_SECRET="$( creds_path /admin_password )"
export BOSH_CA_CERT="$( creds_path /director_ssl/ca )"
export BOSH_GW_HOST="$( state_path /instance_groups/name=bosh/networks/name=default/static_ips/0 2>/dev/null )"
export BOSH_GW_USER="jumpbox"
export BAT_PRIVATE_KEY="$( creds_path /jumpbox_ssh/private_key )"

export BAT_DNS_HOST="$( state_path /instance_groups/name=bosh/networks/name=default/static_ips/0 2>/dev/null )"

export BAT_INFRASTRUCTURE=softlayer
export BAT_NETWORKING=dynamic

export BAT_RSPEC_FLAGS="--tag ~vip_networking --tag ~manual_networking --tag ~root_partition --tag ~raw_ephemeral_storage"

export BAT_DIRECTOR=$( state_path /instance_groups/name=bosh/networks/name=default/static_ips/0 2>/dev/null )
EOF

cat > interpolate.yml <<EOF
---
cpi: softlayer
properties:
  bosh_ip: ((BOSH_ENVIRONMENT))
  use_static_ip: false
  use_vip: false
  pool_size: 1
  instances: 1
  stemcell:
    name: ((STEMCELL_NAME))
    version: latest
  cloud_properties:
    hostname_prefix: ((SL_VM_NAME_PREFIX))
    datacenter: ((SL_DATACENTER))
    domain: ((SL_VM_DOMAIN))
  networks:
  - name: default
    type: dynamic
    cloud_properties:
      vlan_ids:
      - ((SL_VLAN_PUBLIC))
      - ((SL_VLAN_PRIVATE))
  password: "\$6\$Uamn2Hix6MlWro\$UijJSdv4AHPcQIh7T/2tuJAGSY6gq0bseo7wzRfMqzvnco.sPfSJbVCqijixg5VvVdZ2GbPq6uDDieoytK0be/"
  dns:
  - ((BOSH_ENVIRONMENT))
  - 8.8.8.8
  - 10.0.80.11
  - 10.0.80.12
EOF

bosh-cli interpolate \
 --vars-file environment/metadata \
 -v STEMCELL_NAME=${STEMCELL_NAME} \
 -v SL_VM_NAME_PREFIX=${SL_VM_NAME_PREFIX} \
 -v SL_DATACENTER=${SL_DATACENTER} \
 -v SL_VM_DOMAIN=${SL_VM_DOMAIN} \
 -v BOSH_ENVIRONMENT="$( state_path /instance_groups/name=bosh/networks/name=default/static_ips/0 2>/dev/null )" \
 -v SL_VLAN_PUBLIC=${SL_VLAN_PUBLIC} \
 -v SL_VLAN_PRIVATE=${SL_VLAN_PRIVATE} \
 interpolate.yml \
 > bats-config/bats-config.yml
