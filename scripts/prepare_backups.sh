#!/bin/bash

COMMAND_PREFIX=""

# Check if manual or debug run otherwise ensure the user is root for cron execution
if [[ $# == 1 && $1 == "--manual" ]]; then
    COMMAND_PREFIX="sudo"
elif [[ $# == 1 && $1 == "--debug" ]]; then
    COMMAND_PREFIX="echo"
elif [ "$EUID" != 0 ]; then
    echo "Prepare Backups must be run as root user"
    exit 1
fi

function load_env_details() {
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    source "$SCRIPT_DIR/../.env"
}

function execute_prepare_scripts() {
    PREPARE_DIR="$SCRIPT_DIR/prepare"

    for file in "$PREPARE_DIR/"*; do
        $COMMAND_PREFIX bash "$file"
    done
}

load_env_details
execute_prepare_scripts