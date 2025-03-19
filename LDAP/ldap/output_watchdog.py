import time
import os
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class LogHandler(FileSystemEventHandler):
    def __init__(self, log_file, output_file):
        self.log_file = os.path.abspath(log_file)  # Convertir en chemin absolu
        self.output_file = os.path.abspath(output_file)
        self.last_position = 0  # Démarre au début du fichier

        # Vérifier si le fichier log existe et a du contenu
        if os.path.exists(self.log_file) and os.path.getsize(self.log_file) > 0:
            self.last_position = os.path.getsize(self.log_file)

    def on_modified(self, event):
        """Détecte les modifications et met à jour output_file"""
        if os.path.abspath(event.src_path) == self.log_file:
            # Vérifier si le fichier est vide avant d'écrire
            if os.path.getsize(self.log_file) == 0:
                return

            with open(self.log_file, "r") as f:
                f.seek(self.last_position)  
                new_lines = f.readlines()
                self.last_position = f.tell()  

            if new_lines:  
                with open(self.output_file, "a") as out_file:
                    out_file.writelines(new_lines)
                    out_file.flush() 

def start_watching(log_file, output_file):
    event_handler = LogHandler(log_file, output_file)
    observer = Observer()
    observer.schedule(event_handler, path=os.path.dirname(event_handler.log_file), recursive=False)
    observer.start()

    print(f"📡 Surveillance du fichier : {log_file}")

    try:
        while True:
            # Vérifier si le fichier ldap.log existe et n'est pas vide
            if not os.path.exists(log_file) or os.path.getsize(log_file) == 0:
                time.sleep(1)  # Attendre sans rien faire
                continue

            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

def main():
    log_file = "ldap.log"
    output_file = "output_log.txt"

    # Créer output_log.txt s'il n'existe pas
    if not os.path.exists(output_file):
        open(output_file, "w").close()

    # Vérifier que ldap.log existe
    if not os.path.exists(log_file):
        print(f"🚨 Erreur : Le fichier {log_file} n'existe pas. Ajoutez-le d'abord.")
        return

    start_watching(log_file, output_file)

if __name__ == "__main__":
    main()
