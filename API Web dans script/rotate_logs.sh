#!/bin/bash

set -euo pipefail
umask 077
trap 'echo "[ERREUR] Ligne $LINENO." >&2' ERR

# Répertoire des logs
LOG_DIR="$HOME/logs_api_pays"
ARCHIVE_DIR="$LOG_DIR/archives"
ERROR_LOG="$LOG_DIR/rotation_errors.log"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')

# Adresse email de destination
DEST_EMAIL="ton.email@gmail.com"
MAIL_SUBJECT="Archive des logs API - $DATE"
MAIL_CMD="mailx"  # ou "msmtp" selon ce que tu utilises

# Crée le dossier archive si inexistant
mkdir -p "$ARCHIVE_DIR"

# Archive les fichiers logs
ARCHIVE_NAME="$ARCHIVE_DIR/logs_api_$DATE.tar.gz"
tar -czf "$ARCHIVE_NAME" -C "$LOG_DIR" --exclude="archives" -- *.log || {
    echo "[ERREUR] Échec de l'archivage." >> "$ERROR_LOG"
    exit 1
}

# Envoie l'archive par mail (commande à adapter selon config mail locale)
if command -v "$MAIL_CMD" &>/dev/null; then
    echo "Logs API archivés le $DATE" | "$MAIL_CMD" -a "$ARCHIVE_NAME" -s "$MAIL_SUBJECT" "$DEST_EMAIL"
else
    echo "[ERREUR] Commande de mail '$MAIL_CMD' introuvable." >> "$ERROR_LOG"
fi

# Supprime les logs originaux après envoi
find "$LOG_DIR" -maxdepth 1 -name "*.log" -type f -delete

echo "[INFO] Rotation et envoi effectués avec succès le $DATE."
