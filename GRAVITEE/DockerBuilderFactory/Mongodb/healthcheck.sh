#!/bin/sh
set -x  # active le debug

status=$(supervisorctl status mongo | awk '{print $2}')
if [ "$status" != "RUNNING" ]; then
  echo "Mongo process is not running (status=$status)"
  exit 1
fi

ping_result_ssl=$(mongo --host mongo.infra.docker \
  --ssl \
  --sslPEMKeyFile /opt/mongo/tls/backend.pem \
  --sslCAFile /opt/mongo/tls/vault-ca.crt \
  --quiet --eval 'db.runCommand({ping:1}).ok')

echo "Ping result is: '$ping_result_ssl'"

if [ "$ping_result_ssl" != "1" ]; then
  echo "Mongo ping failed (result=$ping_result_ssl)"
  exit 1
fi

exit 0
