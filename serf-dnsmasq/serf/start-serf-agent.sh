#!/bin/bash

service dnsmasq start

SERF_CONFIG_DIR=/etc/serf

# if JOIN_IP env variable set generate a config json for serf
[[ -n $JOIN_IP ]] && cat > $SERF_CONFIG_DIR/join.json <<EOF
{
  "start_join" : ["$JOIN_IP"]
}
EOF

#serf agent -rpc-addr=$(hostname -i):7373 -bind=$(hostname -i) -event-handler=/etc/serf-events.sh -node=$(hostname -f) "$JOIN_OPTS"
#[[ -n $JOIN_IP ]] && JOIN_OPTS="-join=$JOIN_IP"
#serf agent -rpc-addr=0.0.0.0:7373 "$JOIN_OPTS"

cat > $SERF_CONFIG_DIR/node.json <<EOF
{
  "node_name" : "$(hostname -f)"
}
EOF

/bin/serf agent -config-dir $SERF_CONFIG_DIR
