#!/bin/bash
set -euo pipefail

INPUT="$1"

if [ ! -f "$INPUT" ]; then
    echo "[ERROR] Input image not found: $INPUT"
    exit 1
fi

command -v file >/dev/null || {
    echo "[ERROR] file utility not installed"
    exit 1
}

command -v lz4 >/dev/null || {
    echo "[ERROR] lz4 not installed"
    exit 1
}

echo "[INFO] Input:"
file "$INPUT"

if file "$INPUT" | grep -q "LZ4 compressed data"; then
    echo "[INFO] Decompressing LZ4 image..."
    cp "$INPUT" r.img.lz4
    lz4 -d -f r.img.lz4 r.img
else
    echo "[INFO] Using raw image..."
    cp "$INPUT" r.img
fi

if [ ! -f phh.pem ]; then
    echo "[INFO] Generating AVB key..."
    openssl genrsa -out phh.pem 4096
fi

echo "[OK] Stage 1 completed."
