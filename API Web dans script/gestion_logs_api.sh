#!/bin/bash

set -euo pipefail
umask 077
trap 'zenity --error --text="Erreur à la ligne $LINENO."' ERR

LOG_DIR="$HOME/logs_api_pays"
ARCHIVE_DIR="$LOG_DIR/archives"
ERROR_LOG="$LOG_DIR/rotation_errors.log"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')

MAIL_CMD="mailx"
DEST_EMAIL="ton.email@gmail.com"

mkdir -p "$LOG_DIR" "$ARCHIVE_DIR"

CHOIX=$(zenity --list --title="Gestion des logs API" --radiolist \
  --column="Choix" --column="Action" \
  TRUE "Consulter les logs" \
  FALSE "Archiver les logs" \
  FALSE "Envoyer les logs archivés par mail" \
  FALSE "Supprimer les logs archivés")

case $CHOIX in

  "Consulter les logs")
    FICHIER=$(zenity --file-selection --title="Choisis un fichier log à consulter" --filename="$LOG_DIR/")
    [[ -f "$FICHIER" ]] && zenity --text-info --filename="$FICHIER" --title="Contenu du log"
    ;;

  "Archiver les logs")
    NB_LOGS=$(find "$LOG_DIR" -maxdepth 1 -name "*.log" | wc -l)
    if [[ $NB_LOGS -eq 0 ]]; then
      zenity --warning --text="Aucun fichier log à archiver."
      exit 0
    fi

    ARCHIVE="$ARCHIVE_DIR/logs_api_$DATE.tar.gz"
    tar -czf "$ARCHIVE" -C "$LOG_DIR" --exclude="archives" -- *.log && \
    zenity --info --text="Logs archivés dans : $ARCHIVE"

    find "$LOG_DIR" -maxdepth 1 -name "*.log" -type f -delete
    ;;

  "Envoyer les logs archivés par mail")
    ARCHIVE_FILE=$(zenity --file-selection --title="Choisis une archive à envoyer" --filename="$ARCHIVE_DIR/")
    [[ ! -f "$ARCHIVE_FILE" ]] && exit 1

    echo "Logs API envoyés automatiquement le $DATE" | \
    $MAIL_CMD -a "$ARCHIVE_FILE" -s "Archive des logs API - $DATE" "$DEST_EMAIL" && \
    zenity --info --text="Archive envoyée à $DEST_EMAIL"
    ;;

  "Supprimer les logs archivés")
    find "$ARCHIVE_DIR" -name "*.tar.gz" -exec rm -f {} \;
    zenity --info --text="Tous les fichiers archivés ont été supprimés."
    ;;

  *)
    zenity --error --text="Action inconnue ou annulée."
    ;;
esac
