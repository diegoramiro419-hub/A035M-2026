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

############################################
# Logging
############################################

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

die() {
    log "[ERROR] $*"
    exit 1
}

############################################
# Apply Hex Patch
############################################

apply_patch() {

    local OLD_HEX="$1"
    local NEW_HEX="$2"

    log "Applying patch: ${OLD_HEX:0:8}..."

    if "$MAGISKBOOT" hexpatch system/bin/recovery \
        "$OLD_HEX" \
        "$NEW_HEX"; then

        log "[OK] Patch applied."

    else

        log "[WARN] Pattern not found (ignored)."

    fi
}

############################################
# Variables
############################################

MAGISKBOOT="$TOOLS_DIR/magiskboot"
AVBTOOL="$TOOLS_DIR/avbtool.py"

[ -x "$MAGISKBOOT" ] || die "magiskboot not found."
[ -f "$AVBTOOL" ] || die "avbtool.py not found."
[ -f "$WORK_DIR/r.img" ] || die "r.img not found."

############################################
# Unpack Recovery
############################################

cd "$WORK_DIR"

rm -rf unpack
mkdir -p unpack

cd unpack

log "Unpacking recovery image..."

if ! "$MAGISKBOOT" unpack ../r.img; then
    die "Unable to unpack recovery image."
fi

############################################
# Detect Ramdisk
############################################

log "Detecting ramdisk..."

ramdisk=""

for file in \
    ramdisk.cpio \
    vendor_ramdisk/recovery.cpio \
    vendor_ramdisk_recovery.cpio \
    recovery_ramdisk.cpio \
    vendor_ramdisk.cpio
do
    if [ -f "$file" ]; then
        ramdisk="$file"
        break
    fi
done

if [ -z "$ramdisk" ]; then
    ramdisk=$(find . -type f -name "vendor_ramdisk*.cpio" | head -n1)
fi

[ -n "$ramdisk" ] || die "Compatible ramdisk not found."

log "Ramdisk detected: $ramdisk"

############################################
# Extract Ramdisk
############################################

log "Extracting ramdisk..."

if ! "$MAGISKBOOT" cpio "$ramdisk" extract; then
    die "Unable to extract ramdisk."
fi

############################################
# Verify Recovery Binary
############################################

[ -f system/bin/recovery ] || die "system/bin/recovery not found."

log "Recovery binary found."

############################################
# Apply Samsung Recovery Patches
############################################

log "Applying Samsung Recovery patches..."

apply_patch "e10313aaf40300aa6ecc009420010034" "e10313aaf40300aa6ecc0094"
apply_patch "eec3009420010034" "eec3009420010035"
apply_patch "3ad3009420010034" "3ad3009420010035"
apply_patch "50c0009420010034" "50c0009420010035"
apply_patch "080109aae80000b4" "080109aae80000b5"
apply_patch "20f0a6ef38b1681c" "20f0a6ef38b9681c"
apply_patch "23f03aed38b1681c" "23f03aed38b9681c"
apply_patch "20f09eef38b1681c" "20f09eef38b9681c"
apply_patch "26f0ceec30b1681c" "26f0ceec30b9681c"
apply_patch "24f0fcee30b1681c" "24f0fcee30b9681c"
apply_patch "27f02eeb30b1681c" "27f02eeb30b9681c"
apply_patch "b4f082ee28b1701c" "b4f082ee28b9701c"
apply_patch "9ef0f4ec28b1701c" "9ef0f4ec28b9701c"
apply_patch "9ef00ced28b1701c" "9ef00ced28b9701c"
apply_patch "2001597ae0000054" "2001597ae1000054"
apply_patch "2001597ac0000054" "2001597ac1000054"
apply_patch "9ef0fcec28b1701c" "9ef0fced28b1701c"
apply_patch "24f0f2ea30b1681c" "24f0f2ea30b9681c"
apply_patch "e0031f2a8e000014" "200080528e000014"
apply_patch "41010054a0020012f44f48a9" "4101005420008052f44f48a9"

log "All patches processed."

############################################
# Verify Patched Binary
############################################

[ -f system/bin/recovery ] || die "Patched recovery binary missing."

############################################
# Update Ramdisk
############################################

log "Updating ramdisk..."

"$MAGISKBOOT" cpio "$ramdisk" \
'add 0755 system/bin/recovery system/bin/recovery'

############################################
# Repack Recovery
############################################

log "Repacking recovery..."

if ! "$MAGISKBOOT" repack ../r.img recovery-new.img; then
    die "Unable to repack recovery."
fi

############################################
# Verify Output
############################################

[ -s recovery-new.img ] || die "Repacked image is empty."

############################################
# Save Output
############################################

cp recovery-new.img "$OUTPUT_DIR/recovery.img"

log "Patched recovery saved:"
log "$OUTPUT_DIR/recovery.img"

log "Stage 2 completed successfully."
