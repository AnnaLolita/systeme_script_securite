#!/bin/bash

FILENAME="surveillance_systeme.csv"
INTERFACE="eth0"

# Vérification des commandes nécessaires
for cmd in mpstat ifstat free df; do
  if ! command -v $cmd &> /dev/null; then
    echo "Commande $cmd manquante. Installez-la." >&2
    exit 1
  fi
done

# Création du fichier CSV avec des permissions sûres
umask 077
echo "Date,CPU_Utilisation,Mem_Utilisation,Disque_Utilisation,Reseau_Entrant,Reseau_Sortant" > "$FILENAME"

while true; do
  DATE=$(date "+%Y-%m-%d %H:%M:%S")
  CPU=$(mpstat 1 1 | awk '/Average/ { printf "%.2f", 100 - $NF }')
  MEM=$(free | awk '/Mem:/ { printf "%.2f%%", $3/$2*100 }')
  DISK=$(df -h --output=pcent,used,size / | tail -1 | xargs)
  NETWORK=$(ifstat -i "$INTERFACE" 1 1 | tail -n 1 | awk '{print $1 "," $2}')
  echo "$DATE,$CPU,$MEM,$DISK,$NETWORK" >> "$FILENAME"
  sleep 5
done
