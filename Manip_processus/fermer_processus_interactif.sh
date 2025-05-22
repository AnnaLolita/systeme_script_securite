#!/bin/bash

while true; do
  echo ""
  echo "===== MENU - Gestion des processus ====="
  echo "1) Afficher tous les processus"
  echo "2) Afficher uniquement mes processus"
  echo "3) Rechercher un processus par mot-clé"
  echo "4) Quitter"
  echo "========================================"
  read -p "Choisissez une option [1-4] : " choix

  case $choix in
    1)
      echo "--- Liste de tous les processus actifs (top 20 CPU) ---"
      ps aux --sort=-%cpu | awk '{print $1, $2, $3, $11}' | head -n 20
      ;;
    2)
      echo "--- Vos processus actifs (top 20 CPU) ---"
      ps -u $USER --sort=-%cpu | awk '{print $1, $2, $3, $11}' | head -n 20
      ;;
    3)
      read -p "Entrez un mot-clé (ex: firefox, python) : " mot
      echo "--- Processus contenant '$mot' ---"
      ps aux | grep -i "$mot" | grep -v grep | awk '{print $1, $2, $3, $11}'
      ;;
    4)
      echo "Fin du script."
      exit 0
      ;;
    *)
      echo "Option invalide."
      continue
      ;;
  esac

  echo ""
  read -p "Entrez le PID du processus à tuer (ou appuyez sur Entrée pour annuler) : " pid

  if [ -n "$pid" ]; then
    if ps -p $pid > /dev/null; then
      read -p "Souhaitez-vous envoyer SIGTERM (15) ou SIGKILL (9) ? [15/9] : " signal
      if [[ "$signal" == "15" ]]; then
        kill $pid && echo "Processus $pid tué avec SIGTERM."
      elif [[ "$signal" == "9" ]]; then
        kill -9 $pid && echo "Processus $pid tué avec SIGKILL."
      else
        echo "Signal invalide. Aucune action."
      fi
    else
      echo "Le PID $pid n'existe pas."
    fi
  else
    echo "Action annulée."
  fi
done
