#!/bin/bash
#
# Recovery Patcher 2026
# Samsung Galaxy A03 SM-A035M Android 13
#

set -Eeuo pipefail

TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
LOG_DIR="$WORKSPACE/logs"
LOG_FILE="$LOG_DIR/build.log"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

die() {
    log "[ERROR] $*"
    exit 1
}

download() {

    local url="$1"
    local output="$2"

    for i in 1 2 3
    do
        log "Download attempt $i : $(basename "$output")"

        if curl -L --fail --retry 3 --retry-delay 2 \
            -o "$output" "$url"; then

            chmod +x "$output"
            return 0

        fi

        sleep 2

    done

    return 1

}

#############################################

log "====================================="
log "Recovery Patcher 2026"
log "Download Tools"
log "====================================="

ARCH=$(uname -m)

log "Runner architecture : $ARCH"

#############################################

MAGISKBOOT="$TOOLS_DIR/magiskboot"
AVBTOOL="$TOOLS_DIR/avbtool.py"

#
# CAMBIAR CUANDO PUBLIQUES TU RELEASE
#
MAGISKBOOT_URL="https://github.com/TU_USUARIO/Recovery-Patcher-2026/releases/latest/download/magiskboot"

AVBTOOL_URL="https://github.com/TU_USUARIO/Recovery-Patcher-2026/releases/latest/download/avbtool.py"

#############################################

if [ ! -f "$MAGISKBOOT" ]; then

    log "magiskboot not found."

    download "$MAGISKBOOT_URL" "$MAGISKBOOT" \
        || die "Unable to download magiskboot"

else

    log "magiskboot found."

fi

#############################################

if [ ! -f "$AVBTOOL" ]; then

    log "avbtool.py not found."

    download "$AVBTOOL_URL" "$AVBTOOL" \
        || die "Unable to download avbtool.py"

else

    log "avbtool.py found."

fi

#############################################

chmod +x "$MAGISKBOOT"

#############################################

if [ ! -x "$MAGISKBOOT" ]; then
    die "magiskboot is not executable."
fi

if [ ! -f "$AVBTOOL" ]; then
    die "avbtool.py missing."
fi

#############################################

log "Checking tools..."

"$MAGISKBOOT" --help >/dev/null 2>&1 || true

python3 "$AVBTOOL" version >/dev/null 2>&1 || true

#############################################
# SHA256 (opcional)
#############################################

if command -v sha256sum >/dev/null 2>&1; then

    log "magiskboot SHA256:"
    sha256sum "$MAGISKBOOT" | tee -a "$LOG_FILE"

    log "avbtool.py SHA256:"
    sha256sum "$AVBTOOL" | tee -a "$LOG_FILE"

fi

#############################################

log "Tools verified successfully."

log "====================================="
