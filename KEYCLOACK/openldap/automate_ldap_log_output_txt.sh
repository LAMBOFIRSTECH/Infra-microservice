#!/bin/bash

# Définition des couleurs
colors() {
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    CYAN="\033[1;36m"
    NC="\033[0m"
    printf "${!1}${2}${NC}\n"
}

# Vérifier si inotifywait est installé
if ! command -v inotifywait &> /dev/null; then
    colors "RED" "❌ inotify-tools n'est pas installé. Installe-le avec : sudo apt install inotify-tools"
    exit 1
fi

# Fichier à surveiller
file_to_watch="output_log.txt"

# Liste des scripts Python à exécuter après watchdog
scripts=("logs_threatment.py" "./RabbitLibrary/rabbit_context.py" "rabbitmq_producer.py")

# Démarrer watchdog_script.py en arrière-plan et s'assurer qu'il tourne
watchdog_log="output_watchdog.log"
watchdog_script="output_watchdog.py"

nohup python3 "$watchdog_script" > "$watchdog_log" 2>&1 &
watchdog_pid=$!
colors "CYAN" "🚀 Lancement de $watchdog_script (PID: $watchdog_pid)"

# Vérifier que output_log.txt existe, sinon le créer
if [ ! -f "$file_to_watch" ]; then
    touch "$file_to_watch"
    colors "YELLOW" "⚠ $file_to_watch n'existait pas, il a été créé."
fi

# Boucle infinie pour surveiller output_log.txt
while true; do
    # Vérifier si watchdog tourne toujours
    if ! ps -p $watchdog_pid > /dev/null; then
        colors "RED" "❌ $watchdog_script s'est arrêté ! Relancement..."
        nohup python3 "$watchdog_script" > "$watchdog_log" 2>&1 &
        watchdog_pid=$!
        colors "CYAN" "🚀 Relancé : $watchdog_script (PID: $watchdog_pid)"
    fi

    for script_name in "${scripts[@]}"; do
        log_file="${script_name%.py}.log"

        # Lancer le script en arrière-plan
        nohup python3 "$script_name" > "$log_file" 2>&1 &
        pid=$!
        colors "CYAN" "🚀 Lancement de $script_name (PID: $pid)"

        # Attendre que le processus se termine
        wait $pid

        # Si rabbitmq_producer.py réussit, on attend une modification
        if [ "$script_name" == "rabbitmq_producer.py" ]; then
            colors "GREEN" "✅ $script_name terminé avec succès ! Attente d'une modification..."
            inotifywait -q -e modify "$file_to_watch"
            colors "YELLOW" "🔄 Modification détectée ! Redémarrage des scripts..."
            break
        fi

        colors "RED" "⚠ $script_name s'est arrêté ! En attente d'une modification..."
    done
done
