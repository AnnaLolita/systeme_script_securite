#!/bin/bash

FICHIER="personnes.csv"

if [ ! -f "$FICHIER" ]; then
  echo "Erreur : le fichier $FICHIER n'existe pas."
  exit 1
fi

while true; do
  echo ""
  echo "===== MENU - Analyse des villes ====="
  echo "1) Afficher la liste triée des villes"
  echo "2) Afficher les villes uniques"
  echo "3) Compter les occurrences de chaque ville"
  echo "4) Afficher les lignes où la ville est 'Paris'"
  echo "5) Afficher les personnes dont la ville commence par 'T'"
  echo "6) Quitter"
  echo "======================================"
  read -p "Choisissez une option [1-6] : " choix

  case $choix in
    1)
      echo "--- Villes triées (avec doublons) ---"
      awk -F ',' 'NR > 1 {print $3}' "$FICHIER" | sort
      ;;
    2)
      echo "--- Villes uniques ---"
      awk -F ',' 'NR > 1 {print $3}' "$FICHIER" | sort | uniq
      ;;
    3)
      echo "--- Occurrences de chaque ville ---"
      awk -F ',' 'NR > 1 {print $3}' "$FICHIER" | sort | uniq -c
      ;;
    4)
      echo "--- Lignes où la ville est 'Paris' ---"
      awk -F ',' 'NR == 1 || $3 == "Paris"' "$FICHIER"
      ;;
    5)
      echo "--- Villes commençant par 'T' ---"
      awk -F ',' 'NR == 1 || $3 ~ /^T/' "$FICHIER"
      ;;
    6)
      echo "Fin du programme."
      exit 0
      ;;
    *)
      echo "Option invalide. Veuillez choisir un numéro entre 1 et 6."
      ;;
  esac
done
