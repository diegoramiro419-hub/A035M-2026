#!/bin/bash
#
# Recovery Patcher 2026
# Samsung Galaxy A03 SM-A035M Android 13
# Stage 1 - Prepare Recovery Image
#

set -Eeuo pipefail

TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"

WORK_DIR="$WORKSPACE/work"
LOG_DIR="$WORKSPACE/logs"

mkdir -p "$WORK_DIR"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/build.log"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

die() {
    log "[ERROR] $*"
    exit 1
}

############################################

INPUT="${1:-}"

[ -z "$INPUT" ] && die "Usage: script1.sh recovery.img"

[ -f "$INPUT" ] || die "Recovery image not found."

############################################

log "======================================="
log "Stage 1 : Prepare Image"
log "======================================="

############################################

log "Input file"

file "$INPUT" | tee -a "$LOG_FILE"

SIZE=$(stat -c%s "$INPUT")

log "Image Size : $SIZE bytes"

############################################

if file "$INPUT" | grep -q "LZ4 compressed data"; then

    log "Compression : LZ4"

    cp "$INPUT" "$WORK_DIR/recovery.img.lz4"

    log "Decompressing..."

    lz4 -d -f \
        "$WORK_DIR/recovery.img.lz4" \
        "$WORK_DIR/r.img"

else

    log "Compression : NONE"

    cp "$INPUT" "$WORK_DIR/r.img"

fi

############################################

[ -f "$WORK_DIR/r.img" ] || die "Unable to create r.img"

############################################

IMAGE_TYPE=$(file "$WORK_DIR/r.img")

log "$IMAGE_TYPE"

############################################

if [ ! -f "$TOOLS_DIR/phh.pem" ]; then

    log "Generating AVB private key..."

    openssl genrsa \
        -out "$TOOLS_DIR/phh.pem" \
        4096

fi

############################################

if [ ! -f "$TOOLS_DIR/phh.pem" ]; then
    die "Unable to create phh.pem"
fi

############################################

log "Image ready."

log "Output :"

ls -lh "$WORK_DIR" | tee -a "$LOG_FILE"

log "Stage 1 completed successfully."

log "======================================="
