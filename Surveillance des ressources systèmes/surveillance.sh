#!/bin/bash

# Affiche le titre
echo "=== Surveillance des ressources système ==="

while true; do
    # Affiche l'utilisation du CPU, de la mémoire, et des disques
    clear
    echo "== CPU Utilisation ==" 
    mpstat | grep "Average" | awk '{print "CPU Usage: "$3"%"}'

    echo ""
    echo "== Mémoire ==" 
    free -h | grep Mem | awk '{print "Mémoire utilisée: "$3"/"$2" ("$3/$2*100"%)"}'

    echo ""
    echo "== Disques ==" 
    df -h | grep "^/dev" | awk '{print $1" - "$5" utilisé - "$3"/"$2" libre"}'

    # Attendre 2 secondes avant de redémarrer
    sleep 2
done
