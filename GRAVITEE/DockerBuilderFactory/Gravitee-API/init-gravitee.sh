#!/bin/sh

# Définir les couleurs
colors() {
    local COLOR=$1
    local TEXT=$2

    case $COLOR in
    "RED") CODE="\033[0;31m" ;;
    "GREEN") CODE="\033[0;32m" ;;
    "YELLOW") CODE="\033[1;33m" ;;
    "CYAN") CODE="\033[1;36m" ;;
    *) CODE="\033[0m" ;;
    esac

    NC="\033[0m"
    printf "${CODE}%s${NC}\n" "$TEXT"
}

# Vérifier si des fichiers .yaml existent dans le répertoire
DIR="/opt/gravitee-mgnt/config"
rm $DIR/gravitee.yml
FILES=$(ls $DIR/*.yml 2>/dev/null)

# Vérifier si le résultat est vide
if [ -z "$FILES" ]; then
    colors "RED" "❌ Les fichiers de configuration yml n'existent pas."
    exit 1
fi

# Créer le répertoire de destination si nécessaire et concaténer les fichiers YAML
cat $DIR/*.yml > $DIR/gravitee.yml
# Lancement du serveur Gravitee
java -jar /opt/gravitee-mgnt/lib/gravitee-apim-rest-api-standalone-bootstrap-4.7.5.jar