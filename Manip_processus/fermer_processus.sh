#!/bin/bash

# Affiche tous les processus actifs avec leur PID et commande
echo "Voici la liste des processus actifs :"
ps aux --sort=-%cpu | awk '{print $1, $2, $3, $11}' | head -n 20

echo ""
# Demander à l'utilisateur d'entrer un PID à tuer
read -p "Entrez le PID du processus à tuer : " pid

# Vérifier si le PID existe
if ps -p $pid > /dev/null; then
  echo "Vous avez choisi de tuer le processus avec PID $pid."
  read -p "Souhaitez-vous envoyer SIGTERM (arrêt propre) ou SIGKILL (arrêt forcé) ? (tapez 15 pour SIGTERM ou 9 pour SIGKILL) : " signal
  
  # Si l'utilisateur choisit SIGTERM (par défaut)
  if [[ "$signal" == "15" ]]; then
    kill $pid
    echo "Processus $pid tué avec le signal SIGTERM."
  # Si l'utilisateur choisit SIGKILL (forcé)
  elif [[ "$signal" == "9" ]]; then
    kill -9 $pid
    echo "Processus $pid tué avec le signal SIGKILL."
  else
    echo "Signal invalide. Aucun processus tué."
  fi
else
  echo "Aucun processus trouvé avec le PID $pid."
fi
