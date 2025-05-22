#!/bin/bash

# Vérifie si Zenity est installé
if ! command -v zenity &> /dev/null; then
  zenity --error --text="Zenity n'est pas installé. Veuillez l'installer avec : sudo apt install zenity"
  exit 1
fi

# Liste des processus formatée : PID | Commande
liste_processus=$(ps -e -o pid=,comm= --sort=-%cpu | head -n 20 | awk '{printf "%s | %s\n", $1, $2}')

# Choisir un processus
choix=$(echo "$liste_processus" | zenity --list \
  --title="Sélectionner un processus à tuer" \
  --column="PID | Commande" \
  --height=400 --width=500)

# Vérifie si un choix a été fait
if [ -z "$choix" ]; then
  zenity --info --text="Aucun processus sélectionné."
  exit 0
fi

# Extraire le PID du choix
pid=$(echo "$choix" | awk -F '|' '{print $1}' | tr -d ' ')

# Choisir le type de signal
signal=$(zenity --list --radiolist \
  --title="Méthode d'arrêt" \
  --column="Choix" --column="Signal" \
  TRUE "SIGTERM (arrêt propre)" \
  FALSE "SIGKILL (arrêt forcé)")

# Appliquer le signal
if [[ "$signal" == *"SIGTERM"* ]]; then
  kill "$pid" && zenity --info --text="Processus $pid arrêté avec SIGTERM."
elif [[ "$signal" == *"SIGKILL"* ]]; then
  kill -9 "$pid" && zenity --info --text="Processus $pid arrêté avec SIGKILL."
else
  zenity --warning --text="Aucun signal envoyé."
fi

