#!/bin/bash
# ElmoreLab TEON (x1 Interlude) — automated setup script
# Downloads the prepared client, extracts it, creates a Wine prefix,
# downloads the updater, and prepares everything for play.
#
# Usage: ./setup.sh [install_dir]
#   install_dir  Where to install (default: ~/L2ElmoreTeon)

set -euo pipefail

INSTALL_DIR="${1:-$HOME/L2ElmoreTeon}"
WINEPREFIX="$HOME/.wine-l2teon"
MEGA_URL="https://mega.nz/file/7RNGSJza#B2fs_wbrJ5D5E7v-U7PZxkEF1GrQeWv8LQGJApUN47E"
UPDATER_URL="https://elmorelab.com/files/updater_teon/Updater.zip"

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; exit 1; }

# --- dependency check ---
for cmd in wine python3 7z wget unzip megadl; do
    command -v "$cmd" >/dev/null 2>&1 || error "Missing dependency: $cmd (try: sudo apt install megatools)"
done

# --- download client ---
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [ -d "client/system" ]; then
    info "Client already extracted, skipping download."
else
    ARCHIVE="ElmoreTeon.7z"
    if [ ! -f "$ARCHIVE" ]; then
        info "Downloading prepared Interlude client from Mega (~2-3 GB)..."
        megadl --path="$ARCHIVE" "$MEGA_URL"
    else
        info "Archive already downloaded."
    fi

    info "Extracting (this may take a while)..."
    7z x -y "$ARCHIVE"

    # Find the extracted directory — name may vary
    EXTRACTED=$(find . -maxdepth 1 -type d ! -name '.' | head -1)
    if [ -z "$EXTRACTED" ]; then
        error "Extraction produced no directory. Check archive contents."
    fi

    # If there's a nested dir with system/, use it; otherwise rename as-is
    if [ -d "$EXTRACTED/system" ]; then
        mv "$EXTRACTED" client
    elif [ -d "system" ]; then
        mkdir -p client
        mv system client/
    else
        mv "$EXTRACTED" client
    fi

    rm -f "$ARCHIVE"
    info "Extracted and cleaned up."
fi

# --- wine prefix ---
if [ -d "$WINEPREFIX" ]; then
    info "Wine prefix already exists at $WINEPREFIX"
else
    info "Creating 32-bit Wine prefix at $WINEPREFIX..."
    WINEPREFIX="$WINEPREFIX" WINEARCH=win32 wineboot --init 2>/dev/null
    info "Wine prefix created."
fi

# --- updater ---
info "Downloading updater..."
wget -q -O updater.zip "$UPDATER_URL" || warn "Could not download updater. You may need to update manually."
if [ -f updater.zip ]; then
    unzip -o updater.zip -d client/ 2>/dev/null || true
    rm -f updater.zip
    if [ -f "client/Updater.exe" ]; then
        info "Running updater (close the window when it finishes)..."
        cd client
        WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine Updater.exe || true
        cd "$INSTALL_DIR"
    fi
fi

info ""
info "Setup complete!"
info "Register at: https://profile.elmorelab.com/"
info "Launch the game with: ./play.sh"
