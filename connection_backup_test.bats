#!/usr/bin/env bats

load 'test/test_helper'

setup() {
  export RUNNING_IN_TEST_ENV=true
  export BACKUP_PATH="./backups"
  export BACKUP_DAYS=7

  echo "BACKUP_PATH: ${BACKUP_PATH}"
  echo "BACKUP_DAYS: ${BACKUP_DAYS}"

  mkdir -p "${BACKUP_PATH}/backups_compressed"

  # Create test files
  touch -d "10 days ago" "${BACKUP_PATH}/test_old_backup.sql"
  touch -d "5 days ago" "${BACKUP_PATH}/test_recent_backup.sql"
  touch -d "10 days ago" "${BACKUP_PATH}/backups_compressed/test_old_backup.sql.gz"
  touch -d "5 days ago" "${BACKUP_PATH}/backups_compressed/test_recent_backup.sql.gz"
}

teardown() {
  # Teardown code here. This runs after each test.
  rm -rf "${BACKUP_PATH}/test_recent_backup.sql"
  rm -rf "${BACKUP_PATH}/backups_compressed/test_recent_backup.sql.gz"

  unset BACKUP_PATH
  unset BACKUP_DAYS
}

@test "Backup directory is created if it doesn't exist" {
  run mkdir -p "${BACKUP_PATH}"
  [ "$status" -eq 0 ]
}

@test "Old uncompressed backups are deleted" {
  run source connection_backup.sh
  [ ! -f "${BACKUP_PATH}/test_old_backup.sql" ]
}

@test "Recent uncompressed backups are not deleted" {
  run source connection_backup.sh
  [ -f "${BACKUP_PATH}/test_recent_backup.sql" ]
}

@test "Old compressed backups are deleted" {
  run source connection_backup.sh
  [ ! -f "${BACKUP_PATH}/backups_compressed/test_old_backup.sql.gz" ]
}

@test "Recent compressed backups are not deleted" {
  run source connection_backup.sh
  [ -f "${BACKUP_PATH}/backups_compressed/test_recent_backup.sql.gz" ]
}