#!/bin/bash
# Prepares and creates a backup file for plex database

if [ "$EUID" != 0 ]; then
    echo "Backup plex database must be run as root user"
    exit 1
fi

function load_env_details() {
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    source "$SCRIPT_DIR/../../.env"
}

function dump_plex_database() {
    # Change to Plex data location
    cd "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/"

    # Dump Plex Database
    echo ".dump metadata_item_settings" | sqlite3 com.plexapp.plugins.library.db | grep -v TABLE | grep -v INDEX > settings.sql
}

function move_to_backup() {
    # Relies on dump_plex_database creating settings.sql first
    mkdir -p "$BACKUP_PATH/plex/"
    mv settings.sql "$BACKUP_PATH/plex/database.sql"
}

load_env_details
dump_plex_database
move_to_backup
