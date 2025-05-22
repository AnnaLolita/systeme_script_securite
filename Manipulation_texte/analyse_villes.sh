#!/bin/bash

# Fichier source
FICHIER="personnes.csv"

# Vérifier que le fichier existe
if [ ! -f "$FICHIER" ]; then
  echo "Le fichier $FICHIER n'existe pas."
  exit 1
fi

echo "----- 1. Liste des villes (avec doublons, triées) -----"
awk -F ',' 'NR > 1 {print $3}' "$FICHIER" | sort

echo ""
echo "----- 2. Liste des villes uniques -----"
awk -F ',' 'NR > 1 {print $3}' "$FICHIER" | sort | uniq

echo ""
echo "----- 3. Comptage des occurrences par ville -----"
awk -F ',' 'NR > 1 {print $3}' "$FICHIER" | sort | uniq -c

echo ""
echo "----- 4. Lignes où la ville est Paris -----"
awk -F ',' 'NR == 1 || $3 == "Paris"' "$FICHIER"

echo ""
echo "----- 5. Personnes dont la ville commence par T -----"
awk -F ',' 'NR == 1 || $3 ~ /^T/' "$FICHIER"


