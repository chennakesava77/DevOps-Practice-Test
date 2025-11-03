#!/bin/bash
set -e

SRC_DIR=$1
DEST_DIR=$2
TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")
BACKUP_FILE="$DEST_DIR/backup-$TIMESTAMP.tar.gz"
CHECKSUM_FILE="$BACKUP_FILE.md5"

# ✅ Ensure logs directory exists
mkdir -p "$DEST_DIR/logs"
LOG_FILE="$DEST_DIR/logs/backup.log"

log() {
    echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

cleanup_old_backups() {
    log "INFO: Starting cleanup (keeping last 7 backups)"
    ls -tp "$DEST_DIR"/backup-*.tar.gz 2>/dev/null | tail -n +8 | xargs -I {} rm -- {}
    log "INFO: Cleanup complete"
}

log "INFO: Starting backup from $SRC_DIR to $DEST_DIR"
tar -czf "$BACKUP_FILE" -C "$SRC_DIR" .
log "SUCCESS: Backup created: $BACKUP_FILE"

md5sum "$BACKUP_FILE" > "$CHECKSUM_FILE"
log "INFO: Checksum created at $CHECKSUM_FILE"

md5sum -c "$CHECKSUM_FILE"
log "SUCCESS: Checksum verified successfully"

cleanup_old_backups
log "INFO: Backup completed"

