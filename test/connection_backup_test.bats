#!/usr/bin/env bats
setup() {
  source './connection_backup.sh'
  if [ -f ".env" ]; then
    export $(cat .env | xargs)
  else
    echo ".env file not found"
    exit 1
  fi

  cd "$BATS_TEST_TMPDIR"
}

teardown() {
  rm -rf "$BATS_TEST_TMPDIR"
}

@test "Display help information" {
  run help
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: connection_backup.sh [--help | -h]" ]
}

@test "Performing the Backup" {
  run perform_backup
  [ "$status" -eq 0 ]
  [ -d "${BACKUP_PATH}/backups_compressed" ]
}

@test "Compressing the Backup" {
  run perform_backup
  run compress_backup
  [ "$status" -eq 0 ]
  [ -f "${BACKUP_PATH}/backups_compressed/${BACKUP_NAME}.gz" ]
}

@test "Clean up old compressed backups" {
  mkdir -p "${BACKUP_PATH}/backups_compressed"  
  touch -d "10 days ago" "${BACKUP_PATH}/backups_compressed/old_backup.sql.gz"
  run cleanup_old_backups
  [ "$status" -eq 0 ]
  [ ! -f "${BACKUP_PATH}/backups_compressed/old_backup.sql.gz" ]
}

@test "Clean up old uncompressed backups" {
  mkdir -p "${BACKUP_PATH}/"  
  touch -d "10 days ago" "${BACKUP_PATH}/old_backup.sql"
  run cleanup_old_backups
  [ "$status" -eq 0 ]
  [ ! -f "${BACKUP_PATH}/old_backup.sql" ]
}

@test "Don't Clean up recent backups" {
  mkdir -p "${BACKUP_PATH}/"  
  touch -d "1 day ago" "${BACKUP_PATH}/recent_backup.sql"
  run cleanup_old_backups
  [ "$status" -eq 0 ]
  [ -f "${BACKUP_PATH}/recent_backup.sql" ]
}

@test "Don't Clean up recent compressed backups" {
  mkdir -p "${BACKUP_PATH}/backups_compressed"  
  touch -d "1 day ago" "${BACKUP_PATH}/backups_compressed/recent_backup.sql.gz"
  run cleanup_old_backups
  [ "$status" -eq 0 ]
  [ -f "${BACKUP_PATH}/backups_compressed/recent_backup.sql.gz" ]
}