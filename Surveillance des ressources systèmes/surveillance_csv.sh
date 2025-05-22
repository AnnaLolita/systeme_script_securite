#!/bin/bash

# Nom du fichier CSV où nous enregistrerons les données
FILENAME="surveillance_systeme.csv"

# En-têtes du fichier CSV (titre de chaque colonne)
echo "Date,CPU_Utilisation,Mem_Utilisation,Disque_Utilisation,Reseau_Entrant,Reseau_Sortant" > $FILENAME

# Boucle infinie pour surveiller les ressources système
while true; do
  # Récupérer la date et l'heure actuelles
  DATE=$(date "+%Y-%m-%d %H:%M:%S")

  # Récupérer l'utilisation du CPU (moyenne de l'utilisation des cœurs)
#  CPU=$(mpstat 1 1 | grep "Average" | awk '{print 100 - $12}')  # L'utilisation du CPU est 100% - idle
   CPU=$(mpstat 1 1 | tail -1 | awk '{print 100 - $12}')

  # Récupérer l'utilisation de la mémoire
  MEM=$(free -h | grep Mem | awk '{print $3 "/" $2 " (" $3/$2*100 "%)"}')

  # Récupérer l'utilisation du disque
  DISK=$(df -h | grep "^/dev" | awk '{print $5 " utilisé, " $3 " de " $2}')

  # Récupérer l'activité réseau
  NETWORK=$(ifstat -i eth0 1 1 | tail -n 2 | head -n 1 | awk '{print $1 "," $2}') # Réseau entrant et sortant (modifie 'eth0' selon ton interface)

  # Écrire les données dans le fichier CSV
  echo "$DATE,$CPU,$MEM,$DISK,$NETWORK" >> $FILENAME

  # Attendre 5 secondes avant la prochaine capture
  sleep 5
done
