#!/bin/bash

echo "=== TEST DE SIGTERM vs SIGKILL ==="
echo ""

# Lancer un processus simple (sleep pendant 1000s) en arrière-plan
sleep 1000 &
PID=$!

echo "Processus 'sleep' lancé avec PID : $PID"
echo ""

# Demande quelle méthode utiliser
echo "Méthode de terminaison :"
echo "1 - kill (SIGTERM)"
echo "2 - kill -9 (SIGKILL)"
read -p "Choisissez [1/2] : " choix

case $choix in
  1)
    echo ">> Envoi de SIGTERM au processus $PID..."
    kill $PID
    ;;
  2)
    echo ">> Envoi de SIGKILL au processus $PID..."
    kill -9 $PID
    ;;
  *)
    echo "❌ Choix invalide."
    exit 1
    ;;
esac

# Attendre un peu pour voir si le processus est encore en vie
sleep 1

if ps -p $PID > /dev/null; then
  echo "❗ Le processus $PID est TOUJOURS ACTIF."
else
  echo "✅ Le processus $PID est TERMINÉ."
fi
