🧩 Infra‑Microservice

Infrastructure-focused microservice designed to support and streamline platform components such as networking, service discovery, configuration, and secrets management.Infrastructure-focused microservice designed to support and streamline platform components such as networking, service discovery, configuration, and secrets management.

📁 Project Structure Overview

Below is a summarized tree structure of the project directories, highlighting the major components, their environments, and build contexts. This overview helps understand how the infrastructure is organized and where specific responsibilities are encapsulated.

├── GRAFANA
│   ├── Config/                # Configuration files for OpenTelemetry and Prometheus.
│   ├── Distant-develop/       # Remote deployment configurations (Docker Compose).
│   ├── DockerBuilderFactory/  # Build context with Dockerfile and SSL certificates.
│   ├── config/                # Alternative or legacy telemetry configurations.
│   └── docker-compose.yml     # Grafana service definition.
│
├── GRAVITEE
│   ├── Distant-develop/       # Remote Docker Compose for Gravitee stack.
│   ├── DockerBuilderFactory/  # Modular build structure for Gateway, API, UI, and MongoDB.
│   │   ├── Gravitee-API/      # API configurations, Dockerfile, init scripts.
│   │   ├── Gravitee-Gateway/  # Gateway-specific Dockerfile and certificates.
│   │   ├── Gravitee-Ui/       # UI service Dockerfile and SSL support.
│   │   └── Mongodb/           # MongoDB initialization scripts and secure setup.
│   ├── data-mongo/            # MongoDB volume mount for persistence.
│   └── docker-compose.yml     # Gravitee suite orchestration.
│
├── HARBOR
│   ├── harbor/                # Harbor installer scripts and configuration templates.
│   └── harbor-online-installer-v2.10.0.tgz  # Prepackaged installer archive.
│
├── HASHICORP-VAULT-CONSUL-NOMAD
│   ├── DockerBuilderFactory/  # Build context for Vault, Consul, and Nomad.
│   ├── Env-Dev/               # Dev environment with compose files and init scripts.
│   ├── vault-config/          # Configuration files for Vault and Consul agents.
│   └── vault-data/            # Vault’s persistent secrets and ID files.
│   └── vault-init.sh          # Initialize and unsealed vault secrets.
│   └── vault-auth.sh          # This script automates the secure initialization and configuration of HashiCorp Vault, including secret engines, access policies, AppRole authentication, and dynamic credential management for PostgreSQL, MongoDB services and others ...
│
├── KEYCLOAK
│   ├── Certs/                 # TLS certificates for localhost development.
│   ├── Distant-develop/       # Remote environment Docker Compose.
│   ├── DockerBuilderFactory/  # Docker image building for Keycloak and PostgreSQL backend.
│   └── openldap/              # Logging directory for OpenLDAP backend.
│
├── NEXUS
│   ├── DockerBuilderFactory/  # Custom Docker image for Nexus with startup scripts.
│   ├── Env-DEV/               # Development deployment files.
│   └── docker-compose.yml     # Nexus container definition.
│
├── OPENLDAP
│   ├── DockerBuilderFactory/  # OpenLDAP and phpLDAPadmin build contexts.
│   │   ├── LdapDockerBuilderImage/     # LDAP Docker image setup with SSL and init files.
│   │   └── phpDockerBuilderImage/      # phpLDAPadmin Docker image setup.
│   ├── __ldap/                # Python scripts for audit logging and RabbitMQ logging integration.
│   └── auditlog.sh            # Audit logging activation script.
│
├── PROXY-SERVICES
│   ├── Distant-develop/       # Envoy proxy remote setup.
│   └── DockerBuilderFactory/  # Envoy build context and SSL-secured config.
│
├── RABBITMQ
│   ├── Distant-develop/       # RabbitMQ remote deployment configuration.
│   ├── data/                  # Data persistence folder for message queues.
│   └── docker-compose.yml     # RabbitMQ service setup.
│
├── REDIS
│   ├── DockerBuilderFactory/  # Redis Docker image and secure config.
│   ├── redis-log/             # Logging output directory.
│   └── docker-compose.yml     # Redis deployment file.


📦 Overview of Docker Services and Static IPs.
 [View Repo](https://github.com/LAMBOFIRSTECH/Infra-microservice/blob/main/Ips.md)