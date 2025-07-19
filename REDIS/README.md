redis-cli --tls \
  --cert /opt/redis/tls/backend.crt \
  --key /opt/redis/tls/backend.key \
  --cacert /opt/redis/tls/vault-ca.crt \
  -h redis.infra.docker -p 6379
exporter la variable d'env `REDISCLI_AUTH` en lui donnant le mot de passe (plus secure)