#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
umask 077

trap 'echo "[ERREUR] Ligne $LINENO. Code: $?" >&2; exit 1' ERR INT TERM

# 📦 Vérification des dépendances
for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ La commande '$cmd' est requise. Installez-la." >&2
    exit 1
  fi
done

# 🔗 API REST sécurisée
API_URL="https://restcountries.com/v3.1/name"

# 🎯 Entrée utilisateur
read -rp "Entrez le nom d’un pays (en anglais, ex: France, Japan, Madagascar) : " COUNTRY
if [[ -z "$COUNTRY" || "$COUNTRY" =~ [^a-zA-Z\ ] ]]; then
  echo "❌ Entrée invalide. Veuillez utiliser uniquement des lettres." >&2
  exit 1
fi

# 🌐 Requête API sécurisée
ENCODED_COUNTRY=$(echo "$COUNTRY" | tr ' ' '%20')

HTTP_STATUS=""
RESPONSE=$(HTTP_STATUS=$(curl -s -w "%{http_code}" -o /tmp/api_response.json --fail "$API_URL/$ENCODED_COUNTRY") && echo "$HTTP_STATUS" || echo "000")

# ✅ Vérification du code HTTP
if [[ "$RESPONSE" != "200" ]]; then
  echo "❌ Échec de la requête (code HTTP: $RESPONSE). Vérifiez votre connexion ou le nom du pays." >&2
  exit 1
fi

# 📂 Lecture du fichier temporaire
DATA=$(cat /tmp/api_response.json)

# 🧪 Vérification JSON valide
if ! echo "$DATA" | jq empty 2>/dev/null; then
  echo "❌ Réponse API malformée. Impossible de l'analyser." >&2
  exit 1
fi

# 🧾 Extraction des données
if ! echo "$DATA" | jq -e '.[0]' &>/dev/null; then
  echo "❌ Aucun pays trouvé correspondant à '$COUNTRY'." >&2
  exit 1
fi

echo "🌍 Informations sur le pays :"
echo "$DATA" | jq '.[0] | {
  "Nom": .name.common,
  "Capitale": .capital[0],
  "Region": .region,
  "Population": .population,
  "Langues": (.languages | to_entries | map(.value) | join(", "))
}'
