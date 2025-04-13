#!/bin/bash
exec gosu keycloak /opt/keycloak/bin/kc.sh start "$@"