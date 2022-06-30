#!/bin/bash

# Pulls prepared backups from a specified location on the remote server

# Removes coupling of backed up server knowing where the data gets backed up.
# All data should be pre-prepared by the prepare scripts.

function load_env_details() {
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    ENV_LOCATION="$SCRIPT_DIR/../.env"
    if [[ -f "$ENV_LOCATION" ]]; then
        source "$ENV_LOCATION"
    else
        echo ".env file not found, please create"
    fi
}

function process_backup() {
    # Test if the backup path exists, if it does not yet exist assume we haven't processed
    if ! ssh $TARGET_HOST "test -d $BACKUP_PATH"; then
        echo "Backup not yet prepared, please run prepare_backups.sh on the remote host"
        exit 1
    fi

    # Convert file owner to myself on remote target - Assumes sudo needs no password
    ssh $TARGET_HOST "sudo chown -R $(whoami):$(whoami) $BACKUP_PATH"

    # Copy files back locally
    rsync -avz "$TARGET_HOST":"$BACKUP_PATH" "$TARGET_STORAGE/backup"

    # Remove contents from remote target
    ssh $TARGET_HOST "rm -rf $BACKUP_PATH"

    # Tar backup into dated file
    cd "$TARGET_STORAGE"
    tar czf "$TARGET_HOST.$(date +"%d_%m_%Y").tar.gz" backup/
    # Cleanup
    rm -rf backup/
}

load_env_details
process_backup