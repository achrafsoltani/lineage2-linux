#!/bin/bash
# L2GhostSeason — automated setup script
# Downloads the pre-installed client, extracts it, creates a Wine prefix,
# runs the updater, and prepares everything for play.
#
# Usage: ./setup.sh [install_dir]
#   install_dir  Where to install (default: ~/L2GhostSeason)

set -euo pipefail

INSTALL_DIR="${1:-$HOME/L2GhostSeason}"
WINEPREFIX="$HOME/.wine-l2ghost"
MEDIAFIRE_PAGE="https://www.mediafire.com/file/9v2sm4oh3e2l0hi/Lineage_II_Interlude_Ghostlands_Client_%255Bpre-installed%255D.7z/file"

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; exit 1; }

# --- dependency check ---
for cmd in wine python3 7z wget; do
    command -v "$cmd" >/dev/null 2>&1 || error "Missing dependency: $cmd"
done

# --- download ---
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [ -d "client/system" ]; then
    info "Client already extracted, skipping download."
else
    ARCHIVE="GhostClient.7z"
    if [ ! -f "$ARCHIVE" ]; then
        info "Resolving MediaFire download link..."
        DIRECT_URL=$(python3 -c "
import re, urllib.request
req = urllib.request.Request('$MEDIAFIRE_PAGE', headers={'User-Agent': 'Mozilla/5.0'})
html = urllib.request.urlopen(req).read().decode()
m = re.search(r'href=\"(https://download[^\"]+)\"', html)
print(m.group(1) if m else '')
")
        if [ -z "$DIRECT_URL" ]; then
            error "Could not resolve download link. Download manually from: https://l2ghostseason.com"
        fi
        info "Downloading pre-installed client (~2.4 GB)..."
        wget -O "$ARCHIVE" "$DIRECT_URL"
    else
        info "Archive already downloaded."
    fi

    info "Extracting..."
    7z x -y "$ARCHIVE"
    mv "Lineage II Interlude Ghostlands Client [pre-installed]/Lineage II" client
    rm -rf "Lineage II Interlude Ghostlands Client [pre-installed]"
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
if [ -f "client/L2GhostUpdater.exe" ]; then
    info "Running updater (close the window when it finishes)..."
    cd client
    WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine L2GhostUpdater.exe || true
    cd "$INSTALL_DIR"
fi

# --- launch script ---
LAUNCH_SCRIPT="$INSTALL_DIR/play.sh"
printf '#!/bin/bash\ncd "$(cd "$(dirname "$0")" && pwd)/client/system"\nWINEPREFIX="$HOME/.wine-l2ghost" WINEDEBUG="-all" wine L2.exe\n' > "$LAUNCH_SCRIPT"
chmod +x "$LAUNCH_SCRIPT"

info "Setup complete!"
info "Register an account at: https://l2ghostseason.com/accounts.php"
info "Launch the game with: $LAUNCH_SCRIPT"
