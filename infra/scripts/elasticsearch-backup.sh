#!/bin/bash

# Configuration
BACKUP_DIR="/tmp/elasticsearch-backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="elasticsearch-backup-${TIMESTAMP}"
REPOSITORY_NAME="s3_repository"

# Récupération des variables d'environnement
ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST:-elasticsearch}
ELASTICSEARCH_PORT=${ELASTICSEARCH_PORT:-9200}
ELASTICSEARCH_USER=${ELASTICSEARCH_USER:-elastic}
ELASTICSEARCH_PASSWORD=${ELASTICSEARCH_PASSWORD}
S3_BUCKET=${S3_BUCKET}
S3_REGION=${S3_REGION}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

# Vérification des variables requises
for var in ELASTICSEARCH_HOST ELASTICSEARCH_PORT ELASTICSEARCH_USER ELASTICSEARCH_PASSWORD \
           S3_BUCKET S3_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; do
  if [ -z "${!var}" ]; then
    echo "Erreur: La variable $var n'est pas définie"
    exit 1
  fi
done

# URL Elasticsearch
ES_URL="https://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}"

# Fonction pour exécuter des commandes cURL vers Elasticsearch
es_curl() {
  local method=$1
  local endpoint=$2
  local data=$3
  
  curl -s -k -u "${ELASTICSEARCH_USER}:${ELASTICSEARCH_PASSWORD}" \
    -X "${method}" \
    -H "Content-Type: application/json" \
    -d "${data}" \
    "${ES_URL}${endpoint}"
}

# Fonction pour logger
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Début de la sauvegarde
log "Début de la sauvegarde des indices Elasticsearch"

# Vérification de la connexion à Elasticsearch
log "Vérification de la connexion à Elasticsearch..."
health=$(es_curl "GET" "/_cluster/health?pretty" "" | jq -r '.status')
if [ "$health" != "green" ] && [ "$health" != "yellow" ]; then
  log "Erreur: Le cluster Elasticsearch n'est pas en bonne santé (statut: $health)"
  exit 1
fi

# Création du répertoire de configuration du dépôt S3
REPO_DIR="/tmp/elasticsearch/repository-s3"
mkdir -p "${REPO_DIR}"

# Configuration du client AWS pour le plugin S3
echo "${AWS_ACCESS_KEY_ID}" > "${REPO_DIR}/access_key"
echo "${AWS_SECRET_ACCESS_KEY}" > "${REPO_DIR}/secret_key"

# Création du dépôt S3 s'il n'existe pas
log "Vérification du dépôt S3..."
repo_exists=$(es_curl "GET" "/_snapshot/${REPOSITORY_NAME}?pretty" "" | jq -r '.[]' | wc -l)

if [ "$repo_exists" -eq 0 ]; then
  log "Création du dépôt S3..."
  settings=$(cat <<EOF
{
  "type": "s3",
  "settings": {
    "bucket": "${S3_BUCKET}",
    "region": "${S3_REGION}",
    "base_path": "elasticsearch/snapshots",
    "server_side_encryption": true,
    "storage_class": "STANDARD_IA",
    "max_restore_bytes_per_sec": "100mb",
    "max_snapshot_bytes_per_sec": "100mb"
  }
}
EOF
  )
  
  response=$(es_curl "PUT" "/_snapshot/${REPOSITORY_NAME}?pretty" "${settings}")
  if [ $? -ne 0 ] || [ "$(echo "$response" | jq -r '.acknowledged')" != "true" ]; then
    log "Erreur lors de la création du dépôt S3: $response"
    exit 1
  fi
  log "Dépôt S3 créé avec succès"
else
  log "Le dépôt S3 existe déjà"
fi

# Création du snapshot
log "Création du snapshot ${BACKUP_NAME}..."
snapshot_settings='{
  "indices": "*",
  "ignore_unavailable": true,
  "include_global_state": false,
  "metadata": {
    "taken_by": "scheduled-backup",
    "taken_because": "backup before adding new features"
  }
}'

response=$(es_curl "PUT" "/_snapshot/${REPOSITORY_NAME}/${BACKUP_NAME}?wait_for_completion=true&pretty" "${snapshot_settings}")

if [ $? -ne 0 ] || [ "$(echo "$response" | jq -r '.snapshot.state')" != "SUCCESS" ]; then
  log "Erreur lors de la création du snapshot: $response"
  exit 1
fi

log "Snapshot créé avec succès: ${BACKUP_NAME}"

# Nettoyage des anciens snapshots (conserver les 7 derniers)
log "Nettoyage des anciens snapshots..."
snapshots=$(es_curl "GET" "/_snapshot/${REPOSITORY_NAME}/_all?pretty" "" | jq -r '.snapshots[].snapshot' | sort | head -n -7)

for snapshot in $snapshots; do
  log "Suppression de l'ancien snapshot: $snapshot"
  es_curl "DELETE" "/_snapshot/${REPOSITORY_NAME}/${snapshot}?pretty" ""
done

# Nettoyage des fichiers temporaires
rm -rf "${REPO_DIR}"

log "Sauvegarde Elasticsearch terminée avec succès"
exit 0
