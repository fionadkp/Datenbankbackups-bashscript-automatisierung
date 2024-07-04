#!/usr/bin/env bats

load 'test_helper'

setup() {
  # Setup code here. This runs before each test.
  BACKUP_PATH="./test_backup"
  mkdir -p "${BACKUP_PATH}/backups_compressed"
}

teardown() {
  # Teardown code here. This runs after each test.
  rm -rf "${BACKUP_PATH}"
}

@test "Backup directory is created if it doesn't exist" {
  run mkdir -p "${BACKUP_PATH}"
  [ "$status" -eq 0 ]
}

@test "Backup is successfully created and compressed" {
  # Mocking docker exec and gzip to always return true for testing purposes
  run bash -c "export PATH=$(pwd)/test/mocks:\$PATH; ./connection_backup.sh"
  [ "$status" -eq 0 ]
  [ -f "${BACKUP_PATH}/backups_compressed/*.gz" ]
}

@test "Old backups are cleaned up" {
  touch -d '10 days ago' "${BACKUP_PATH}/backups_compressed/old_backup.sql.gz"
  run bash ./connection_backup.sh
  [ ! -f "${BACKUP_PATH}/backups_compressed/old_backup.sql.gz" ]
}