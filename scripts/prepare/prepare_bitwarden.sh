#!/bin/bash
# Prepares and creates a backup file for bitwarden docker container


if [ "$EUID" != 0 ]; then
    echo "Backup bitwarden must be run as root user"
    exit 1
fi


function load_env_details() {
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    source "$SCRIPT_DIR/../../.env"
}

function password_zip_bitwarden() {
    zip -e -P "$BACKUP_PASSWORD" -r bitwarden_backup.zip "$BITWARDEN_FILE_LOCATION"
}

function move_to_backup() {
    # Relies on password_zip_bitwarden creating bitwarden_backup.zip first
    mkdir -p "$BACKUP_PATH/bitwarden/"
    mv bitwarden_backup.zip "$BACKUP_PATH/bitwarden/bitwarden_backup.zip"
}

load_env_details
password_zip_bitwarden
move_to_backup