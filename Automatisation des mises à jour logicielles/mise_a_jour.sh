#!/bin/bash

# Script pour vérifier et proposer les mises à jour système (Debian)
# Utilisateur : interface MATE ou terminal

# Vérifie que le script est lancé avec les droits root ou sudo
if [ "$EUID" -ne 0 ]; then
  echo "❌ Ce script doit être exécuté avec sudo ou en tant que root."
  exit 1
fi

echo "🔍 Mise à jour de la liste des paquets..."
apt update > /tmp/mises_a_jour.txt 2>&1

# Vérifie s'il y a des mises à jour disponibles
UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -v "Listing..." | wc -l)

if [ "$UPGRADABLE" -eq 0 ]; then
  echo "✅ Tous les paquets sont à jour."
  exit 0
else
  echo "📦 Paquets à mettre à jour :"
  apt list --upgradable 2>/dev/null | grep -v "Listing..."
fi

# Demande à l'utilisateur s'il veut lancer la mise à jour
read -rp "Souhaitez-vous effectuer la mise à jour maintenant ? (o/n) : " REPONSE

if [[ "$REPONSE" =~ ^[Oo]$ ]]; then
  echo "⏳ Mise à jour en cours..."
  apt upgrade -y
  echo "✅ Mise à jour terminée."
else
  echo "⛔ Mise à jour annulée par l'utilisateur."
fi
