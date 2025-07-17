
# Objectif de ce combo 


| Ressource Docker                | Terraform                 | Ansible       |    
| ------------------------------- | --------------------------- --------------| 
| Réseaux (`docker_network`)      | ✅ Terraform              | ⚠️ Non       |
| Volumes (`docker_volume`)       | ✅ Terraform              | ⚠️ Non       |
| Conteneurs (`docker_container`) | ⚠️ Oui, mais peu pratique | ✅ Ansible   | 
| Fichiers de config              | ⚠️ Non                    | ✅ Ansible   | 


| 🔧 Outil      | 🎯 Rôle principal                                                                                                           |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Terraform** | Provisionne l’infrastructure de base :<br>VMs, réseaux, volumes, Docker networks, <br>                                       |
| **Ansible**   | Configure les services sur les VMs :<br>installation de Docker, <br>déploiement de config, secrets, etc.                     |
| **Nomad**     | Orchestration des containers/applications :<br>déploiement, scalabilité, restart, binpacking, HA.                            |