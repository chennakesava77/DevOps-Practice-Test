#!/bin/bash

CONFIG_FILE="backup.config"
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/backup.log"
LOCK_FILE="/tmp/backup.lock"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    [ -f "$LOCK_FILE" ] && rm -f "$LOCK_FILE"
    exit 1
}

usage() {
    echo "Usage:"
    echo "  ./backup.sh <source_directory>"
    echo "  ./backup.sh --dry-run <source_directory>"
    echo "  ./backup.sh --restore <backup_file> --to <destination>"
    echo "  ./backup.sh --list"
    exit 1
}

# Load config
if [ ! -f "$CONFIG_FILE" ]; then
    error_exit "Config file '$CONFIG_FILE' not found!"
fi
source "$CONFIG_FILE"

DRY_RUN=false
RESTORE=false
LIST=false
SOURCE_DIR=""
BACKUP_FILE=""
RESTORE_DIR=""

# Argument parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --restore)
            RESTORE=true
            BACKUP_FILE="$2"
            shift 2
            ;;
        --to)
            RESTORE_DIR="$2"
            shift 2
            ;;
        --list)
            LIST=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            SOURCE_DIR="$1"
            shift
            ;;
    esac
done

# Lock check
if [ -f "$LOCK_FILE" ]; then
    error_exit "Another backup process is running!"
fi
touch "$LOCK_FILE"

create_backup() {
    local TIMESTAMP=$(date +%Y-%m-%d-%H%M)
    local BACKUP_NAME="backup-$TIMESTAMP.tar.gz"
    local DEST_FILE="$BACKUP_DESTINATION/$BACKUP_NAME"

    mkdir -p "$BACKUP_DESTINATION"

    if $DRY_RUN; then
        log "DRY-RUN: Would back up $SOURCE_DIR → $DEST_FILE"
        return
    fi

    log "Backing up $SOURCE_DIR to $DEST_FILE"
    tar -czf "$DEST_FILE" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" || error_exit "Backup failed"
    log "Backup created: $DEST_FILE"
}

restore_backup() {
    if [ -z "$BACKUP_FILE" ] || [ -z "$RESTORE_DIR" ]; then
        usage
    fi

    mkdir -p "$RESTORE_DIR"
    log "Restoring $BACKUP_FILE to $RESTORE_DIR"
    tar -xzf "$BACKUP_FILE" -C "$RESTORE_DIR" || error_exit "Restore failed"
    log "Restore successful to $RESTORE_DIR"
}

list_backups() {
    log "Listing backups in $BACKUP_DESTINATION"
    ls -lh "$BACKUP_DESTINATION"/backup-*.tar.gz 2>/dev/null || log "No backups found"
}

# MAIN LOGIC
if $LIST; then
    list_backups
    rm -f "$LOCK_FILE"
    exit 0
fi

if $RESTORE; then
    restore_backup
    rm -f "$LOCK_FILE"
    exit 0
fi

if [ -z "$SOURCE_DIR" ]; then
    usage
fi

if [ ! -d "$SOURCE_DIR" ]; then
    error_exit "Source directory not found: $SOURCE_DIR"
fi

if $DRY_RUN; then
    log "Dry run enabled"
else
    log "Starting backup for $SOURCE_DIR"
fi

create_backup
rm -f "$LOCK_FILE"
log "Backup process completed."

