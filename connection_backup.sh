#!/bin/bash

help() {
    echo "Usage: connection_backup.sh [--help | -h]"
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
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    help
fi

# Ask the user if they want to change the environment variables for this session
read_env() {
    read -r -p "Do you want to change the environment variables for this session? (y/n): " answer
}

if [[ $answer == "y" || $answer == "Y" ]]; then
    read -r -p "Enter the database username: " DB_USER
    read -r -p "Enter the database password: " DB_PASSWORD
    read -r -p "Enter the database name: " DB_NAME
    read -r -p "Enter the backup path: " BACKUP_PATH
    read -r -p "Enter the number of days to keep backups: " BACKUP_DAYS
else
    # Environment variables
    if [ -f .env ]; then
        export $(cat .env | xargs)
    else
        echo ".env file not found"
        exit 1
fi
fi

BACKUP_NAME="db_backup_$(date +%Y%m%d%H%M%S).sql"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker could not be found. Please install it and try again."
    exit 1
fi

perform_backup() {
    read_env
    mkdir -p "${BACKUP_PATH}/backups_compressed"
    # Perform the backup using mysqldump within the Docker container and save it to the backup directory
    sudo docker exec mariadb mariadb-dump -u "${DB_USER}" -p"${DB_PASSWORD}" -h "${DB_ADDRESS}" -P "${DB_PORT}" "${DB_NAME}" | sudo tee "${BACKUP_PATH}/${BACKUP_NAME}" > /dev/null
    exit_status=$?

    # Check if the backup was successful
    if [ $exit_status -eq 0 ]; then
        echo "Database backup was successful."
        compress_backup
    else
        echo "Backup failed."
        exit $exit_status
    fi

    cleanup_old_backups
}

compress_backup() {
    gzip -c "${BACKUP_PATH}/${BACKUP_NAME}" > "${BACKUP_PATH}/${BACKUP_NAME}.gz"
    # Move the compressed backup file to the backups_compressed folder. compression exists for easy file sharing
    mv "${BACKUP_PATH}/${BACKUP_NAME}.gz" "${BACKUP_PATH}/backups_compressed/${BACKUP_NAME}.gz"
    echo "Backup compressed."
}

cleanup_old_backups() {
    # Cleanup old backups (older than BACKUP_DAYS)
    find "${BACKUP_PATH}" ! -type d -name "*.sql" -mtime +"${BACKUP_DAYS}" -delete
    find "${BACKUP_PATH}/backups_compressed" ! -type d -name "*.sql.gz" -mtime +"${BACKUP_DAYS}" -delete
    echo "Old backups cleaned up."
}

main() {
    perform_backup
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi