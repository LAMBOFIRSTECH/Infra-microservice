# installation de supervisord pour gérer les deux services apache2 et php

## lambops/phpadminldap:no-vuln-alpine3.21 ( c'est déjà sur docker hub et non en local)

    - C'est dans cette image que l'on a installé php et toutes ses dépendances
    - on la reprend et on lance un container avec et  on installe  php-session support before using phpLDAPadmin. puis on rebuild l'image avant de l'utiliser