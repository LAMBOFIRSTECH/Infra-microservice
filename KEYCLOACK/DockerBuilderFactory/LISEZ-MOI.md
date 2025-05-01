# 1- Construction de l'image postgres
## postgres:17-no-vuln-alpine3.21

Image Docker custom PostgreSQL 17 basée sur Alpine 3.21 avec `gosu` compilé statiquement à partir de Go 1.22.4.


### ✅ Objectifs
- 0 vulnérabilités détectées (scannée avec [Trivy](https://github.com/aquasecurity/trivy))
- Image légère (~254MB)
- Binaire gosu statique et sécurisé
- Maintien à jour facile via multi-stage build

### 🔐 Sécurité
- Base Alpine 3.21.3 (à jour)
- PostgreSQL 17 (digest utilisé pour garantir l'intégrité)
- `gosu` compilé sans vulnérabilité connues (Trivy OK)

Report Summary

┌────────────────────────────────────────────────┬──────────┬─────────────────┬─────────┐
│                     Target                     │   Type   │ Vulnerabilities │ Secrets │
├────────────────────────────────────────────────┼──────────┼─────────────────┼─────────┤
│ postgres:17-no-vuln-alpine3.21 (alpine 3.21.3) │  alpine  │        0        │    -    │
├────────────────────────────────────────────────┼──────────┼─────────────────┼─────────┤
│ usr/local/bin/gosu                             │ gobinary │        0        │    -    │
└────────────────────────────────────────────────┴──────────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)



### 🛠 Usage
```bash
docker run -d --name postgres-secure -e POSTGRES_PASSWORD=secret lambops/postgres:17-no-vuln-alpine3.21 
```
# 2-Construction de l'image keycloak
## lambops/keyclaok:secure

Image Docker custom KEYCLOAK 26.2.2 basée sur Alpine 3.21 avec `gosu` compilé statiquement à partir de Go 1.22.4.


### ✅ Objectifs
- 0 vulnérabilités détectées (scannée avec [Trivy](https://github.com/aquasecurity/trivy))
- Image légère (~350MB)
- Binaire gosu statique et sécurisé
- Maintien à jour facile via multi-stage build

### 🔐 Sécurité
- Base golang:alpine3.21
- Alpine 3.21.3 (digest)
- keycloak 26.2.2 (depuis la source  https://github.com/keycloak/keycloak/releases/download/26.2.2/keycloak-26.2.2.tar.gz)
- `gosu` compilé sans vulnérabilité connues (Trivy OK)
- user gosu : keycloak 

### 🛠 Exécution du binaire keycloak dans l'image
```bash
exec gosu keycloak /opt/keycloak/bin/kc.sh start "$@"
```

Report Summary

┌──────────────────────────────────────────────────────────────────────────────────┬──────────┬─────────────────┬─────────┐
│                                      Target                                      │   Type   │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────────────────────────────────────────────┼──────────┼─────────────────┼─────────┤
│ lambops/keycloak:26.2.2 (alpine 3.21.3)                                          │  alpine  │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼──────────┼─────────────────┼─────────┤
