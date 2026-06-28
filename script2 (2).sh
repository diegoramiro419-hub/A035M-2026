#!/bin/bash
#
# Recovery Patcher 2026
# Samsung Galaxy A03 SM-A035M Android 13
# Stage 2 - Patch Recovery
#

set -Eeuo pipefail

TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"

WORK_DIR="$WORKSPACE/work"
OUTPUT_DIR="$WORKSPACE/output"
LOG_DIR="$WORKSPACE/logs"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/build.log"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

die() {
    log "[ERROR] $*"
    exit 1
}

MAGISKBOOT="$TOOLS_DIR/magiskboot"

[ -x "$MAGISKBOOT" ] || die "magiskboot not found."

[ -f "$WORK_DIR/r.img" ] || die "r.img not found."

cd "$WORK_DIR"

rm -rf unpack
mkdir unpack
cd unpack

log "Unpacking recovery..."

"$MAGISKBOOT" unpack ../r.img
