#!/bin/bash

# Nom ou ID du conteneur à auditer
container_name="popo"

# Fichier de log nettoyé
clean_log="docker_bench_clean.log"
raw_log="docker_bench_raw.log"

# Vérifier si le conteneur est en cours d'exécution
if docker ps --format '{{.Names}}' | grep -q "^$container_name$"; then
    echo "Le conteneur '$container_name' est actif."

    # Récupérer son image
    image=$(docker inspect --format='{{.Config.Image}}' "$container_name")
    echo "Image utilisée par '$container_name' : $image"

    # Lancer Docker Bench for Security
    echo "Lancement de Docker Bench for Security..."
    docker run --privileged --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /etc:/etc docker/docker-bench-security \
        > "$raw_log" 2>&1

    # Nettoyer les séquences ANSI du log
    sed -r 's/\x1B\[[0-9;]*[mK]//g' "$raw_log" > "$clean_log"
    rm -f "$raw_log"

    echo "Audit terminé. Résultat nettoyé enregistré dans : $clean_log"
else
    echo "Le conteneur '$container_name' n'est pas actif. Aucun audit effectué."
fi

#nohup ./bench_docker.sh   2>&1 &
