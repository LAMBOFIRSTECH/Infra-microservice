#!/bin/bash

container_name="popo"

# Vérifier si le conteneur est actif
if ! docker ps --format '{{.Names}}' | grep -q "^$container_name$"; then
    echo "Le conteneur '$container_name' n'est pas actif."
    exit 1
fi

echo "🔍 Audit du conteneur : $container_name"

# Inspecter le conteneur
docker inspect "$container_name" > inspect.json

# Extraire les données clés
echo "✅ Sécurité du conteneur :"
jq '.[0] | {
  ID: .Id,
  Image: .Config.Image,
  CapAdd: .HostConfig.CapAdd,
  CapDrop: .HostConfig.CapDrop,
  Privileged: .HostConfig.Privileged,
  ReadonlyRootfs: .HostConfig.ReadonlyRootfs,
  SeccompProfile: .HostConfig.SecurityOpt,
  AppArmorProfile: .AppArmorProfile,
  User: .Config.User
}' inspect.json

rm -f inspect.json
