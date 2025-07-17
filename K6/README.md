# L'objectif est de stresser au maximum nos services pour valider leur solidité avant l'environnement de production

| Situation                      | Pourquoi c’est utile                                     |
| ------------------------------ | -------------------------------------------------------- |
| Après un déploiement via Nomad | Vérifier la résistance des services Docker               |
| Test de scalabilité            | Savoir à partir de combien d’utilisateurs les API saturent |
| Intégration CI/CD              | Tester à chaque build que la perf ne chute pas           |

A la fin il faudra :
Envoyer des métriques à Grafana
bash ```
k6 run --out influxdb=http://influxdb:8086/mydb montee_charge_api.k6.js
``` 