#!/bin/bash

# Vérifie que Zenity est installé
if ! command -v zenity &> /dev/null; then
  echo "Zenity n'est pas installé. Installe-le avec : sudo apt install zenity"
  exit 1
fi

# Lancer un processus simple (sleep) en arrière-plan
sleep 1000 &
PID=$!

zenity --info --text="Le processus 'sleep' a été lancé avec le PID : $PID"

# Choix du type de terminaison
choix=$(zenity --list --radiolist \
  --title="Test de terminaison de processus" \
  --column="Choix" --column="Méthode" \
  TRUE "SIGTERM (arrêt propre)" \
  FALSE "SIGKILL (arrêt forcé)")

if [ -z "$choix" ]; then
  kill $PID
  zenity --info --text="Test annulé. Processus terminé."
  exit 0
fi

# Appliquer la terminaison choisie
if [[ "$choix" == *"SIGTERM"* ]]; then
  kill $PID
  signal="SIGTERM"
elif [[ "$choix" == *"SIGKILL"* ]]; then
  kill -9 $PID
  signal="SIGKILL"
fi

# Pause pour laisser le temps au signal d'agir
sleep 1

# Vérifier si le processus est toujours actif
if ps -p $PID > /dev/null; then
  zenity --warning --text="⚠️ Le processus $PID est toujours actif après $signal."
else
  zenity --info --text="✅ Le processus $PID a été terminé avec succès via $signal."
fi
