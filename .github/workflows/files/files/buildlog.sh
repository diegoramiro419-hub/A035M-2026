#!/bin/bash
#
# Recovery Patcher 2026
# Build Log Generator
#

set -Eeuo pipefail

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"

LOG_DIR="$WORKSPACE/logs"
OUTPUT_DIR="$WORKSPACE/output"

mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/build.log"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

############################################
# Build Summary
############################################

log "========================================"
log "Recovery Patcher 2026"
log "Build Summary"
log "========================================"

log "Device        : Samsung Galaxy A03 SM-A035M"
log "Android       : 13"

if [ -f "$OUTPUT_DIR/recovery.img" ]; then

    SIZE=$(stat -c%s "$OUTPUT_DIR/recovery.img")
    SIZE_MB=$((SIZE / 1024 / 1024))

    log "Output File   : recovery.img"
    log "Size          : ${SIZE_MB} MB"
    log "Status        : SUCCESS"

else

    log "Status        : FAILED"
    log "Output file not found."

    exit 1

fi

log "========================================"
log "Build completed successfully."
log "========================================"
