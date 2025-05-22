#!/bin/bash

# Définir les variables
SOURCE_DIR="$HOME/Documents/Plateforme"  # Répertoire à sauvegarder
BACKUP_DIR="$HOME/Sauvegardes"           # Répertoire où les sauvegardes seront stockées
DATE=$(date "+%Y%m%d_%H%M%S")            # Horodatage pour la sauvegarde
BACKUP_FILE="$BACKUP_DIR/plateforme_$DATE.tar.gz"  # Nom du fichier de sauvegarde
LOG_FILE="$BACKUP_DIR/historique_sauvegardes.log"  # Fichier log pour l'historique

# Créer le répertoire de sauvegarde s'il n'existe pas déjà
mkdir -p "$BACKUP_DIR"

# Créer une archive compressée du répertoire "Plateforme"
tar -czf "$BACKUP_FILE" -C "$SOURCE_DIR" . 

# Vérifier si la sauvegarde a réussi
if [ $? -eq 0 ]; then
  # Enregistrer dans le fichier log avec un message de réussite
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Sauvegarde réussie : $BACKUP_FILE" >> $LOG_FILE
  echo "La sauvegarde a été réalisée avec succès : $BACKUP_FILE"
else
  # Enregistrer dans le fichier log avec un message d'échec
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Échec de la sauvegarde : $BACKUP_FILE" >> $LOG_FILE
  echo "Erreur lors de la sauvegarde."
fi

