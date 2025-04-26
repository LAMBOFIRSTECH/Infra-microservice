## Construction d'une image de base légère alpine

- [X] : Golang gosu pour un utitilsateur non root
- [X] : Alpine 3.21 (digest basé sur l'arch amd64) sans vulnérabilités
- [X] : Création d'un utlisateur local
- [X] : Création des fichiers .env et builder.sh pour charger les variables d'environnement
- [X] : Lancement du build avec `docker build --build-arg LOCAL_USER=value --build-arg USER_WORKDIR=value -t lambops/base:no-vuln-alpine3.21 .`
