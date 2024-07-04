#!/bin/bash

if [ "$1" == "-help" ]; then
    echo "Usage: $0 [-help]"
    echo "This script backs up a MariaDB database. It saves the backup to a specified directory and compresses it using gzip."
    echo ""
    echo "Options:"
    echo "  -help  Display this help message and exit."
    echo ""
    echo "Environment Variables:"
    echo "  DB_USER       Database username"
    echo "  DB_PASSWORD   Database password"
    echo "  DB_NAME       Database name to back up"
    echo "  BACKUP_PATH   Path where backups are saved"
    echo "  BACKUP_DAYS   Number of days to keep backups"
    exit 0
fi

# Variables
DB_USER="1234"
DB_PASSWORD="1234"
DB_NAME="mariadb"

DB_ADDRESS="localhost"
DB_PORT="3306"

BACKUP_PATH="./backups"
BACKUP_NAME="db_backup_$(date +%Y%m%d%H%M%S).sql"
BACKUP_DAYS=7  # Number of days to keep backups. Checks for files older than this value and deletes them.

# Check if mysqldump is installed
if ! command -v mysqldump &> /dev/null; then
    echo "mysqldump could not be found. Please install it and try again."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker could not be found. Please install it and try again."
    exit 1
fi


# Create the backup directory if it doesn't exist
mkdir -p "${BACKUP_PATH}"

# Perform the backup using mysqldump within the Docker container and save it to the backup directory
sudo docker exec mariadb mariadb-dump -u "${DB_USER}" -p"${DB_PASSWORD}" -h "${DB_ADDRESS}" -P "${DB_PORT}" "${DB_NAME}" > "${BACKUP_PATH}/${BACKUP_NAME}"
exit_status=$?

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Database backup was successful."
    # make a compressed copy of the backup file
    gzip "${BACKUP_PATH}/${BACKUP_NAME}"
    # Move the compressed backup file to the backups_compressed folder
    mv "${BACKUP_PATH}/${BACKUP_NAME}.gz" "${BACKUP_PATH}/backups_compressed/${BACKUP_NAME}.gz"
    echo "Backup compressed."
else
    echo "Backup failed."
    exit $exit_status
fi

# Cleanup old backups (older than BACKUP_DAYS)
find "${BACKUP_PATH}" -type f -name "*.sql.gz" -mtime +${BACKUP_DAYS} -exec rm {} \;
echo "Old backups cleaned up."