import ast
import json
import time

def read_log():
    try:
       file = open("output_log.txt", 'r') 
       return file.read()  
    except FileNotFoundError:
        print("File not found")
        exit(1)
 
# il me faut une librairie pour mieux organiser les traitements sur le fichier log
def extract_block(file):
    inside_block = False
    block = []
    blocks = []  # Liste pour stocker tous les blocs extraits
    current_operation = None  # Variable pour stocker l'opération actuelle
    current_dn = None  # Variable pour stocker le 'dn' du bloc en cours
    for line in file.splitlines():
        # Détection des blocs 'add', 'delete', 'modify' et début d'extraction
        if '# add' in line:
            inside_block = True
            current_operation = 'add'
            block = [line.strip()]  # Commence un nouveau bloc
        elif '# modify' in line:
            inside_block = True
            current_operation = 'modify'
            block = [line.strip()]  # Commence un nouveau bloc
        elif '# delete' in line:
            inside_block = True
            current_operation = 'delete'
            block = [line.strip()]  # Commence un nouveau bloc

        elif '# end' in line and inside_block:  # Fin du bloc
            block.append(line.strip())  # Ajouter la ligne contenant # end
            block_dict = {'operation': current_operation}  # Ajout de l'opération

            for item in block:
                if item.startswith("#") or not item.strip():
                    continue       
                # Diviser la ligne en clé et valeur
                key_value = item.split(": ", 1)  
                if len(key_value) == 2:  # S'assurer que l'élément est valide
                    key, value = key_value
                    # Si la ligne contient un 'dn', on le garde séparément
                    if key == 'dn':
                        current_dn = value
                    # Ajout de la clé et de la valeur au dictionnaire
                    block_dict[key] = value

            # Ajouter le bloc au résultat sous forme de dictionnaire
            blocks.append(block_dict)
            inside_block = False  # Réinitialiser l'extraction du bloc

        elif inside_block:  # Ajouter les lignes dans le bloc si on est à l'intérieur du bloc
            block.append(line.strip())

    return blocks

found_users = []
def extract_data(block_items):
    if len(block_items) == 0:
        print("No data found")
        exit(1)
    data_string= json.dumps(block_items, indent=4)
    try:
        data = ast.literal_eval(data_string)
    except ValueError as e:
        print(f"Erreur de syntaxe dans data_string: {e}")
        data = []
    key_to_check = 'structuralObjectClass'
    value_to_check = 'inetOrgPerson'
    last_matching_item=None
    entryUUID=''
    for item in reversed(data):
        if item.get(key_to_check) == value_to_check:
            last_matching_item = item
            found_users.append(item.get('entryUUID')) # sera utiliser pour la recherche de l'uuid d'un user modifié ou supprimé
            break 
        if item.get('operation') == 'delete' and item.get('dn', '').startswith('cn='):
            cn=item.get('dn').split(',')[0].split('=')[1]
            for x in data:
                if x.get('cn') == cn:
                    entryUUID=x.get('entryUUID')
                    user_dict = {'entryUUID': entryUUID} 
                    break
            item.update(user_dict)
            last_matching_item = item
            break
        # pareil pour les modifications
        if item.get('operation') == 'modify' and item.get('dn', '').startswith('cn='):
            cn=item.get('dn').split(',')[0].split('=')[1]
            for x in data:
                if x.get('cn') == cn:
                    entryUUID=x.get('entryUUID')
                    user_dict = {'entryUUID': entryUUID} 
                    break
            item.update(user_dict)
            last_matching_item = item
            break
        
    if not last_matching_item:
        print("No item matches the condition.")     
    return item


def get_entryuuid(data,message: str):
    if data.get('operation') == 'add' and data.get('structuralObjectClass') == 'inetOrgPerson':
        entryuuid = data.get('entryUUID')
        message = "User created"
        return entryuuid,message
    elif data.get('operation') == 'modify' and data.get('dn', '').startswith('cn='):
        entryuuid = data.get('entryUUID')
        message = "User modified"
        return entryuuid,message
    elif data.get('operation') == 'delete' and data.get('dn', '').startswith('cn='):
        entryuuid = data.get('entryUUID')
        message = "User deleted"
        return entryuuid,message
    else:
        return None,message

def main():
    file = read_log()
    block_items = extract_block(file)  # Traiter chaque ligne dès son arrivée
    data = extract_data(block_items)
    message = ""
    content = get_entryuuid(data, message)
    return content

if __name__ == "__main__":
    main()
