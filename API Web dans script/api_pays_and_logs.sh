#!/bin/bash

set -euo pipefail
umask 077
trap 'zenity --error --text="Erreur à la ligne $LINENO."' ERR

# === CONFIGURATION ===
API_URL="https://restcountries.com/v3.1/name"
LOG_DIR="$HOME/logs_api_pays"
ARCHIVE_DIR="$LOG_DIR/archives"
mkdir -p "$LOG_DIR" "$ARCHIVE_DIR"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
LOG_FILE="$LOG_DIR/api_$DATE.log"
MAIL_CMD="mailx"
DEST_EMAIL="ton.email@gmail.com"

# === CHOIX UTILISATEUR ===
ACTION=$(zenity --list --title="Menu principal" --radiolist \
  --column="Choix" --column="Action" \
  TRUE "Faire une requête API" \
  FALSE "Gérer les logs")

case $ACTION in

  "Faire une requête API")
    PAYS=$(zenity --entry --title="Recherche de pays" --text="Entrez un pays à rechercher :")
    [[ -z "$PAYS" ]] && exit 0

    echo "[$DATE] Requête API vers $API_URL/$PAYS" >> "$LOG_FILE"

    REPONSE=$(curl -s --fail "$API_URL/$PAYS" || echo "")
    if [[ -z "$REPONSE" ]]; then
      echo "[$DATE] ERREUR : Échec de la requête API" >> "$LOG_FILE"
      zenity --error --text="Erreur lors de la récupération des données."
      exit 1
    fi

    echo "[$DATE] Réponse API : $REPONSE" >> "$LOG_FILE"

    # Affichage interactif
    INFO=$(echo "$REPONSE" | jq -r '.[0] | 
      "Nom: \(.name.common)\nRégion: \(.region)\nCapitale: \(.capital[0])\nPopulation: \(.population)\nMonnaie: \(.currencies | to_entries[0].value.name)"' 2>/dev/null)

    if [[ -z "$INFO" ]]; then
      zenity --error --text="Format de réponse inattendu ou pays non trouvé."
      echo "[$DATE] ERREUR : Format de réponse non exploitable" >> "$LOG_FILE"
      exit 1
    fi

    zenity --info --title="Infos sur $PAYS" --text="$INFO"
    ;;

  "Gérer les logs")
    CHOIX=$(zenity --list --title="Gestion des logs API" --radiolist \
      --column="Choix" --column="Action" \
      TRUE "Consulter les logs" \
      FALSE "Archiver les logs" \
      FALSE "Envoyer les logs archivés par mail" \
      FALSE "Supprimer les logs archivés")

    case $CHOIX in
      "Consulter les logs")
        FICHIER=$(zenity --file-selection --title="Choisis un fichier log" --filename="$LOG_DIR/")
        [[ -f "$FICHIER" ]] && zenity --text-info --filename="$FICHIER" --title="Contenu du log"
        ;;
      "Archiver les logs")
        NB_LOGS=$(find "$LOG_DIR" -maxdepth 1 -name "*.log" | wc -l)
        [[ $NB_LOGS -eq 0 ]] && zenity --warning --text="Aucun log à archiver." && exit 0

        ARCHIVE="$ARCHIVE_DIR/logs_api_$DATE.tar.gz"
        tar -czf "$ARCHIVE" -C "$LOG_DIR" --exclude="archives" -- *.log
        zenity --info --text="Logs archivés : $ARCHIVE"
        find "$LOG_DIR" -maxdepth 1 -name "*.log" -type f -delete
        ;;
      "Envoyer les logs archivés par mail")
        ARCHIVE_FILE=$(zenity --file-selection --title="Choisis une archive" --filename="$ARCHIVE_DIR/")
        [[ -f "$ARCHIVE_FILE" ]] || exit 1
        echo "Logs API du $DATE" | $MAIL_CMD -a "$ARCHIVE_FILE" -s "Logs API archivés" "$DEST_EMAIL"
        zenity --info --text="Archive envoyée à $DEST_EMAIL"
        ;;
      "Supprimer les logs archivés")
        find "$ARCHIVE_DIR" -name "*.tar.gz" -exec rm -f {} \;
        zenity --info --text="Archives supprimées."
        ;;
      *) zenity --error --text="Action inconnue." ;;
    esac
    ;;

  *) zenity --error --text="Aucune action sélectionnée." ;;
esac
