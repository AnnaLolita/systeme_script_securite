#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
umask 077

###########################
# CONFIGURATION DU LOGGING
###########################
LOG_DIR="$HOME/logs_api_pays"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date '+%Y-%m-%d').log"

log() {  # log "NIVEAU" "message"
  local level="$1"; shift
  printf '%s [%s] %s\n' "$(date --iso-8601=seconds)" "$level" "$*" >> "$LOG_FILE"
}

trap 'log ERROR "Interruption ou erreur fatale (ligne $LINENO)"; exit 1' ERR INT TERM

###########################
# VÉRIFICATION DÉPENDANCES
###########################
for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    log ERROR "La commande $cmd est manquante"
    echo "❌ $cmd requis. Installez‑le." >&2
    exit 1
  fi
done

###########################
# LECTURE DE L’ENTRÉE
###########################
read -rp "Entrez un pays (en anglais, ex : France, Japan) : " COUNTRY
if [[ -z "$COUNTRY" || "$COUNTRY" =~ [^a-zA-Z\ ] ]]; then
  log WARNING "Entrée invalide: '$COUNTRY'"
  echo "❌ Entrée invalide." >&2
  exit 1
fi

###########################
# APPEL DE L’API
###########################
API_URL="https://restcountries.com/v3.1/name"
ENCODED=$(echo "$COUNTRY" | tr ' ' '%20')
FULL_URL="$API_URL/$ENCODED"

log INFO "Requête API => $FULL_URL"
HTTP_CODE=$(curl -s -w '%{http_code}' -o /tmp/api_resp.json --fail "$FULL_URL" || echo "000")

if [[ "$HTTP_CODE" != "200" ]]; then
  log ERROR "Réponse HTTP $HTTP_CODE pour $COUNTRY"
  echo "❌ Requête échouée (HTTP $HTTP_CODE)." >&2
  exit 1
fi

RESP=$(cat /tmp/api_resp.json)

# Vérifie que le JSON est valide
if ! echo "$RESP" | jq empty 2>/dev/null; then
  log ERROR "JSON malformé pour $COUNTRY"
  echo "❌ Réponse JSON invalide." >&2
  exit 1
fi

log INFO "Réponse API OK (taille $(echo "$RESP" | wc -c) o)"

###########################
# AFFICHAGE FORMATÉ
###########################
echo "$RESP" | jq '.[0] | {
  "Nom": .name.common,
  "Capitale": .capital[0],
  "Region": .region,
  "Population": .population,
  "Langues": (.languages | to_entries | map(.value) | join(", "))
}'

# Option : enregistrer aussi la réponse complète (pratique pour debug)
echo "$RESP" > "$LOG_DIR/$(date '+%Y%m%dT%H%M%S')_${COUNTRY// /_}.json"
log INFO "Réponse JSON sauvegardée."
