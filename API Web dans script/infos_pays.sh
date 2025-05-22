#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
umask 077

# 🚨 Gestion des erreurs
trap 'echo "[ERREUR] Ligne $LINENO. Code: $?" >&2; exit 1' ERR INT TERM

# 📦 Dépendances
REQUIRED_CMDS=("curl" "jq")
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ La commande '$cmd' est requise. Installez-la." >&2
    exit 1
  fi
done

# 🔐 Utilisation d'une API HTTPS sécurisée
API_URL="https://restcountries.com/v3.1/name"

# 🎯 Entrée utilisateur
read -rp "Entrez le nom d’un pays (en anglais, ex: France, Japan) : " COUNTRY
if [[ -z "$COUNTRY" || "$COUNTRY" =~ [^a-zA-Z\ ] ]]; then
  echo "❌ Entrée invalide." >&2
  exit 1
fi

# 📡 Requête sécurisée vers l'API
RESPONSE=$(curl -s --fail "$API_URL/$(echo "$COUNTRY" | tr ' ' '%20')")
if [[ -z "$RESPONSE" ]]; then
  echo "❌ Aucune réponse ou pays non trouvé." >&2
  exit 1
fi

# 🧾 Traitement des données avec jq
echo "Informations sur le pays :"
echo "$RESPONSE" | jq '.[0] | {
  "Nom": .name.common,
  "Capitale": .capital[0],
  "Region": .region,
  "Population": .population,
  "Langues": (.languages | to_entries | map(.value) | join(", "))
}'

