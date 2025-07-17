# Dépot des configurations ansible sur le serveur distant 
## Taches infrastructure à faire pour les images docker que l'on souhaite pousser sur le registry privé

### 1. Construction de l'image docker
- [X] Trivy image <nom_image>
- [] Scripts qui permet de visualiser les vulnérabilités de l'image et imposer des restrictions en fonction des criticités
- [] Gérer aussi la sécurité du conteneur docker dans lequel l'image est déployée


## Tester la connection avec un ping
`ansible-playbook -i inventory.ini main.yaml -v`
`ansible-vault encrypt_string --name 'ansible_password' '!!Art94721805&'` : Pour chiffrer le mot de passe et copier dans l'inventory le passphrase est toto
ansible-playbook -i Win_Config/config_win/hosts Win_Playbook/win_playbooks/ping.yaml --ask-vault-pass -vvv

    ansible_winrm_scheme: http

ansible_winrm_transport: ntlm 
    --> pour les comptes locaux et du domaine
NTLM est le protocole d'authentification le plus simple à utiliser et est plus sécurisé que l'authentification basique. S'il est exécuté dans un environnement de domaine, Kerberos doit être utilisé à la place de NTLM.

Kerberos présente plusieurs avantages par rapport à l'utilisation de NTLM :

NTLM est un protocole plus ancien et ne prend pas en charge les protocoles de chiffrement plus récents.

NTLM est plus lent à s'authentifier car il nécessite davantage d'allers-retours vers l'hôte lors de la phase d'authentification.

Contrairement à Kerberos, NTLM n'autorise pas la délégation d'informations d'identification.

`ansible-playbook -i VM_Config/hosts main.yaml --ask-vault-pass --forks 2 -vv` : la commande de lancement de mon playbook ansible

`ssh -o ProxyCommand="ssh -W %h:%p ansibleWinRm@192.168.1.12" lambo@192.168.153.132`: cette commande permet de se connecterà un jump host puis à nos vm.
`ansible-galaxy role init VM_Config/Linux_roles/<role-name>` : Création d'un role ansible
Créer un lien symmbolique de du fichier hosts vers le dossier `VM_Config/Linux_roles/<role-name>/hosts`

  #"{{ sudo_password }}"
  configurer ssh en root pour déployer sur les serveurs distants

Pour se connecter directement sur la machine srv-prod (ssh -o ProxyCommand="ssh -W %h:%p ansibleWinRm@192.168.1.12"  `-p 222` administrateur@192.168.153.130)