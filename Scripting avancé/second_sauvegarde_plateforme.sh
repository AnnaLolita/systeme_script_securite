#!/bin/bash

# === CONFIGURATION ===
SOURCE_DIR="$HOME/Plateforme"
BACKUP_DIR="$HOME/sauvegardes_plateforme"
LOG_DIR="$HOME/logs_sauvegardes"
RETENTION_DAYS=7

# === PRÉPARATION DES DOSSIERS ===
mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

# === VARIABLES ===
DATE=$(date "+%Y%m%d_%H%M%S")
BACKUP_NAME="Plateforme_${DATE}.tar.gz"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
LOG_FILE="$LOG_DIR/sauvegarde_$(date "+%Y%m%d").log"

# === SAUVEGARDE ===
{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] DÉBUT DE SAUVEGARDE"

  if tar -czf "$BACKUP_PATH" "$SOURCE_DIR"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sauvegarde réussie : $BACKUP_PATH"
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ ERREUR lors de la sauvegarde !"
  fi

  # === ROTATION DES SAUVEGARDES ===
  OLD_FILES=$(find "$BACKUP_DIR" -type f -name "Plateforme_*.tar.gz" -mtime +$RETENTION_DAYS)
  if [ -n "$OLD_FILES" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Suppression des sauvegardes plus vieilles que $RETENTION_DAYS jours :"
    echo "$OLD_FILES"
    echo "$OLD_FILES" | xargs rm -f
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Aucune sauvegarde à supprimer (toutes < $RETENTION_DAYS jours)"
  fi

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] FIN DE SAUVEGARDE"
  echo "------------------------------------------------------------"
} >> "$LOG_FILE" 2>&1
