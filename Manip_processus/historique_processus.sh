#!/bin/bash

LOG_FILE="$HOME/.local/share/gestion_processus/historique.log"

if [ ! -f "$LOG_FILE" ]; then
  zenity --info --text="Aucun historique disponible."
  exit 0
fi

action=$(zenity --list --radiolist \
  --title="Historique des processus arrêtés" \
  --column="Choix" --column="Action" \
  TRUE "Afficher l'historique" \
  FALSE "Vider l'historique")

case "$action" in
  *Afficher*)
    zenity --text-info --filename="$LOG_FILE" --title="Historique des processus"
    ;;
  *Vider*)
    > "$LOG_FILE"
    zenity --info --text="Historique vidé."
    ;;
  *)
    exit 0
    ;;
esac
