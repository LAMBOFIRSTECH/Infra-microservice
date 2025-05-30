# Mettre à jour le SAN dans le certificat 

`openssl s_client -connect proxy.infra.docker:27017 -cert /opt/vault/tls/backend.crt  -key /opt/vault/tls/backend.key -CAfile /opt/vault/tls/vault-ca.crt`
`openssl x509 -in /opt/vault/tls/backend.crt  -text -noout | grep -A 10 "Subject Alternative Name"`

## commande rapide pour tenter la connexion dans mongo en utilisant le proxy

`mongo "mongodb://vault_admin:1234@proxy.infra.docker:27018/gravitee_db?authSource=gravitee_db&tls=true&authMechanism=SCRAM-SHA-256" \
  --ssl \
  --sslPEMKeyFile /opt/mongo/tls/backend.pem \
  --sslCAFile /opt/mongo/tls/vault-ca.crt \
  --authenticationDatabase gravitee_db \
  --authenticationMechanism SCRAM-SHA-256 \
  --verbose`
