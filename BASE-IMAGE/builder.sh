#!/bin/bash

# Vérifie la présence du fichier .env
if [ ! -f .env ]; then
  echo "❌ Fichier .env introuvable."
  exit 1
fi

# Charge les variables du .env
echo "📥 Lecture des variables depuis .env ..."
export $(grep -v '^#' .env | xargs)