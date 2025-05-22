#!/bin/bash

SOURCE_DIR="$HOME/Documents"
BACKUP_DIR="$HOME/Sauvegardes"
LOG_FILE="$BACKUP_DIR/historique.log"
DATE=$(date +"%Y%m%d_%H%M%S")

mkdir -p "$BACKUP_DIR"
umask 077  # permissions restreintes

ARCHIVE="$BACKUP_DIR/backup_$DATE.tar.gz"
tar -czf "$ARCHIVE" "$SOURCE_DIR"

echo "[$(date)] Sauvegarde créée : $ARCHIVE" >> "$LOG_FILE"

# Retirer sauvegardes de plus de 7 jours
find "$BACKUP_DIR" -name "*.tar.gz" -type f -mtime +7 -delete
