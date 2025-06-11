#!/bin/bash

# Configuration
BACKUP_DIR="/tmp/postgres-backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql"
ENCRYPTED_FILE="${BACKUP_FILE}.gpg"

# Récupération des variables d'environnement
PGHOST=${POSTGRES_HOST:-postgres}
PGPORT=${POSTGRES_PORT:-5432}
PGUSER=${POSTGRES_USER:-postgres}
PGPASSWORD=${POSTGRES_PASSWORD}
PGDATABASE=${POSTGRES_DB}

S3_BUCKET=${S3_BUCKET}
S3_REGION=${S3_REGION}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENCRYPTION_KEY=${ENCRYPTION_KEY}

# Vérification des variables requises
for var in PGHOST PGPORT PGUSER PGPASSWORD PGDATABASE S3_BUCKET S3_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY ENCRYPTION_KEY; do
  if [ -z "${!var}" ]; then
    echo "Erreur: La variable $var n'est pas définie"
    exit 1
  fi
done

# Création du répertoire de sauvegarde
mkdir -p "${BACKUP_DIR}"

# Fonction pour logger
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Début de la sauvegarde
log "Début de la sauvegarde de la base de données ${PGDATABASE}"

# Sauvegarde de la base de données
log "Création du dump SQL..."
PGPASSWORD="${PGPASSWORD}" pg_dump -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${PGDATABASE}" -F c -b -v -f "${BACKUP_FILE}"

if [ $? -ne 0 ]; then
  log "Erreur lors de la création du dump SQL"
  exit 1
fi

# Chiffrement du fichier de sauvegarde
log "Chiffrement du fichier de sauvegarde..."
gpg --symmetric --batch --passphrase "${ENCRYPTION_KEY}" -o "${ENCRYPTED_FILE}" "${BACKUP_FILE}"

if [ $? -ne 0 ]; then
  log "Erreur lors du chiffrement du fichier de sauvegarde"
  exit 1
fi

# Téléversement vers S3
log "Téléversement vers S3..."
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  aws s3 cp "${ENCRYPTED_FILE}" "s3://${S3_BUCKET}/postgres/backup_${TIMESTAMP}.sql.gpg" --region "${S3_REGION}"

if [ $? -ne 0 ]; then
  log "Erreur lors du téléversement vers S3"
  exit 1
fi

# Nettoyage des fichiers temporaires
log "Nettoyage des fichiers temporaires..."
rm -f "${BACKUP_FILE}" "${ENCRYPTED_FILE}"

# Vérification des anciennes sauvegardes (conservation des 7 dernières)
log "Nettoyage des anciennes sauvegardes..."
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  aws s3 ls "s3://${S3_BUCKET}/postgres/" --region "${S3_REGION}" | sort | \
  head -n -7 | awk '{print $4}' | while read -r file; do
    if [ -n "$file" ]; then
      log "Suppression de l'ancienne sauvegarde: $file"
      aws s3 rm "s3://${S3_BUCKET}/postgres/${file}" --region "${S3_REGION}"
    fi
done

log "Sauvegarde terminée avec succès: backup_${TIMESTAMP}.sql.gpg"
exit 0
