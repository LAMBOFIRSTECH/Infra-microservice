🧩 Infra‑Microservice

Infrastructure-focused microservice designed to support and streamline platform components such as networking, service discovery, configuration, and secrets management.Infrastructure-focused microservice designed to support and streamline platform components such as networking, service discovery, configuration, and secrets management.

📁 Project Structure Overview

Below is a summarized tree structure of the project directories, highlighting the major components, their environments, and build contexts. This overview helps understand how the infrastructure is organized and where specific responsibilities are encapsulated.


    ```text
    Infra-Microservice/
    ├── AUTOMATION-STACKS/
    │   ├── ANSIBLE-CAC/ 
    |   |   └── Roles                    
    │   ├── TERRAFORM/                 
    │
    ├── GRAFANA/ (Visualisation des métriques)
    │   ├── Config/                 # OpenTelemetry & Prometheus configuration files
    │   ├── Distant-develop/        # Remote deployment configs (Docker Compose)
    │   ├── DockerBuilderFactory/   # Docker build context, Dockerfile & SSL certs
    │   ├── config/                 # Alternative or legacy telemetry configs
    │   └── docker-compose.yml      # Grafana service definition
    │
    ├── GRAVITEE/ (Gestionnaire des API)
    │   ├── Distant-develop/        # Remote Docker Compose for Gravitee stack
    │   ├── DockerBuilderFactory/   # Modular builds for Gateway, API, UI, MongoDB
    │   │   ├── Gravitee-API/       # API configs, Dockerfile & init scripts
    │   │   ├── Gravitee-Gateway/   # Gateway Dockerfile & certificates
    │   │   ├── Gravitee-Ui/        # UI service Dockerfile & SSL support
    │   │   └── Mongodb/            # MongoDB init scripts and secure setup
    │   ├── data-mongo/             # MongoDB persistent data volume mount
    │   └── docker-compose.yml      # Gravitee suite orchestration
    │
    ├── HARBOR/
    │   ├── harbor/                 # Installer scripts & configuration templates
    │   └── harbor-online-installer-v2.10.0.tgz  # Prepackaged installer archive
    │
    ├── HASHICORP-VAULT-CONSUL-NOMAD/ (Gestion des secrets, du sservice discovery et orchestration de conteneur)
    │   ├── DockerBuilderFactory/   # Vault, Consul & Nomad Docker build context
    │   ├── Env-Dev/                # Development environment compose files & init scripts
    │   ├── vault-config/           # Vault and Consul agent configuration files
    │   ├── vault-data/             # Persistent vault secrets and ID files
    │   ├── vault-init.sh           # Vault initialization & unseal scripts
    │   └── vault-auth.sh           # Automates Vault secure setup, policies & credentials management
    │
    ├── KEYCLOAK/ (IAM)
    │   ├── Certs/                  # TLS certificates for local development
    │   ├── Distant-develop/        # Remote Docker Compose environment
    │   ├── DockerBuilderFactory/   # Docker build for Keycloak & PostgreSQL backend
    │   └── openldap/               # OpenLDAP logging directory
    │
    ├── NEXUS/ (Stockage des artéfacts)
    │   ├── DockerBuilderFactory/   # Custom Nexus Docker image & startup scripts
    │   ├── Env-DEV/                # Development deployment files
    │   └── docker-compose.yml      # Nexus container setup
    │
    ├── OPENLDAP/ (Annuaire pour les utilisateurs du système)
    │   ├── DockerBuilderFactory/   # OpenLDAP & phpLDAPadmin build contexts
    │   │   ├── LdapDockerBuilderImage/  # LDAP Docker image with SSL & init files
    │   │   └── phpDockerBuilderImage/   # phpLDAPadmin Docker image setup
    │   └── auditlog.sh             # Audit logging activation script
    │
    ├── PROXY-SERVICES/ (Brigde entre les services d'infra et leur base de données)
    │   ├── Distant-develop/        # Envoy proxy remote setup
    │   └── DockerBuilderFactory/   # Envoy Docker build & SSL-secured config
    │
    ├── RABBITMQ/ (Serveur de messagerie entre les microservices)
    │   ├── Distant-develop/        # RabbitMQ remote deployment configuration
    │   ├── data/                   # RabbitMQ data persistence directory
    │   └── docker-compose.yml      # RabbitMQ service definition
    │
    ├── REDIS/ (Caching pour les microservices)
    │   ├── DockerBuilderFactory/   # Redis Docker image and secure configuration
    │   ├── redis-log/              # Redis log output directory
    │   └── docker-compose.yml      # Redis deployment configuration
    ```



📦 Docker Services and Static IPs
For detailed service IP mappings and Docker networking setup, see the [IP documentation](https://github.com/LAMBOFIRSTECH/Infra-microservice/blob/main/Ips.md)