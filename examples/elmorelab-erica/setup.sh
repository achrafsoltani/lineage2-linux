#!/bin/bash
# ElmoreLab "Erica" (Interlude x3) — automated setup script
#
# Erica is ElmoreLab's Interlude x3 server (launched 22 May 2026, ~5k online,
# 2+1 box limit, no P2W). Like all ElmoreLab servers it has NO kernel-mode
# anticheat — only a server-side in-game CAPTCHA — so it runs fine under Wine.
#
# elmorelab.com sits behind Cloudflare and the client is served via Google Drive
# / MEGA from the download page, so this script never hard-codes a link it can't
# verify. Give it the client archive you downloaded (or a MEGA link), and it will
# extract it, create a dedicated 32-bit Wine prefix, run the Updater (Full Check),
# and write a play.sh launcher.
#
# Usage:
#   ./setup.sh [install_dir]                                   # extracts an archive already in install_dir
#   ERICA_ARCHIVE="$HOME/Downloads/Erica.7z" ./setup.sh        # point at your downloaded client
#   ERICA_MEGA_URL="https://mega.nz/file/XXXX#KEY" ./setup.sh  # download from MEGA via megadl
#
#   install_dir   Where to install (default: ~/L2ElmoreErica)

set -euo pipefail

INSTALL_DIR="${1:-$HOME/Documents/Games/lineage2/elmorelab-erica}"
WINEPREFIX="$HOME/.wine-l2erica"

DOWNLOAD_PAGE="https://elmorelab.com/servers/erica/download.html"
REGISTER_URL="https://profile.elmorelab.com/account/register"

ERICA_ARCHIVE="${ERICA_ARCHIVE:-}"     # path to a client archive you already downloaded
ERICA_MEGA_URL="${ERICA_MEGA_URL:-}"   # MEGA link copied from the download page

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; exit 1; }

manual_instructions() {
    cat >&2 <<EOF

--------------------------------------------------------------------------
 No client archive found — manual download needed
--------------------------------------------------------------------------
The Erica client is served via Google Drive / MEGA behind Cloudflare, so this
script will not guess a URL. Do this, then re-run:

 1. Register:  $REGISTER_URL
 2. Download the Erica x3 Interlude client from:  $DOWNLOAD_PAGE

 Then EITHER point the script at the file:
     ERICA_ARCHIVE="\$HOME/Downloads/<the-file>.7z" ./setup.sh
 OR drop the archive into:  $INSTALL_DIR   and re-run:  ./setup.sh
 OR pass a MEGA link:        ERICA_MEGA_URL="https://mega.nz/file/XXXX#KEY" ./setup.sh
--------------------------------------------------------------------------
EOF
}

# --- dependency check (megadl/unzip only needed for the MEGA path / zipped updater) ---
for cmd in wine python3 7z wget; do
    command -v "$cmd" >/dev/null 2>&1 || \
        error "Missing dependency: $cmd (try: sudo apt install wine p7zip-full p7zip-rar wget unzip megatools)"
done

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# --- locate / download the client ---
if [ -d "client/system" ] && [ -f "client/system/L2.exe" ]; then
    info "Client already extracted, skipping download."
else
    ARCHIVE=""
    if [ -n "$ERICA_ARCHIVE" ] && [ -f "$ERICA_ARCHIVE" ]; then
        ARCHIVE="$ERICA_ARCHIVE"
        info "Using provided archive: $ARCHIVE"
    elif [ -n "$ERICA_MEGA_URL" ]; then
        command -v megadl >/dev/null 2>&1 || error "MEGA link given but 'megadl' missing (sudo apt install megatools)"
        ARCHIVE="$INSTALL_DIR/Erica.client"
        if [ ! -f "$ARCHIVE" ]; then
            info "Downloading Erica client from MEGA via megadl..."
            megadl --path="$ARCHIVE" "$ERICA_MEGA_URL" || error "megadl failed — download manually instead."
        fi
    else
        # reuse an archive already sitting in the install dir
        found="$(find . -maxdepth 1 -type f \( -iname '*.7z' -o -iname '*.zip' -o -iname '*.rar' \) | head -1 || true)"
        ARCHIVE="${found#./}"
    fi

    if [ -z "$ARCHIVE" ] || [ ! -f "$ARCHIVE" ]; then
        manual_instructions
        info "Nothing to extract yet — exiting cleanly. Follow the steps above, then re-run."
        exit 0
    fi

    info "Extracting $ARCHIVE (this can take a while)..."
    7z x -y "$ARCHIVE" >/dev/null || error "Extraction failed (RAR client? install p7zip-rar / unrar)."

    # normalise so that ./client/system/L2.exe exists
    if [ -d "client/system" ]; then
        :
    elif [ -d "system" ]; then
        mkdir -p client && mv system client/
        for d in maps textures systextures animations sounds music staticmeshes voice movies guard; do
            [ -d "$d" ] && mv "$d" client/ 2>/dev/null || true
        done
    else
        sys="$(find . -maxdepth 4 -type d -iname system | head -1 || true)"
        [ -n "$sys" ] || error "No 'system' folder found in the archive. Inspect $INSTALL_DIR manually."
        root="$(dirname "$sys")"
        [ "$root" = "./client" ] || mv "$root" client
    fi
    info "Client ready at $INSTALL_DIR/client"
fi

# --- 32-bit Wine prefix ---
if [ -d "$WINEPREFIX" ]; then
    info "Wine prefix already exists at $WINEPREFIX"
else
    info "Creating 32-bit Wine prefix at $WINEPREFIX..."
    WINEPREFIX="$WINEPREFIX" WINEARCH=win32 wineboot --init 2>/dev/null
    info "Wine prefix created."
fi

# --- run the ElmoreLab updater (patches client + bakes the Erica server connection) ---
exe="$(find client -maxdepth 2 -type f -iname 'Updater*.exe' | head -1 || true)"
if [ -n "$exe" ]; then
    info "Running the Erica Updater — click 'Full Check', let it finish, then close it..."
    ( cd "$(dirname "$exe")" && WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine "./$(basename "$exe")" ) || true
else
    warn "No Updater.exe found in the client. Grab the Erica updater from $DOWNLOAD_PAGE,"
    warn "place it in $INSTALL_DIR/client/ and run it once before playing."
fi

# --- launcher ---
cat > "$INSTALL_DIR/play.sh" <<'LAUNCH'
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$SCRIPT_DIR/client/system"
WINEPREFIX="$HOME/.wine-l2erica"
if [ ! -f "$SYSTEM_DIR/L2.exe" ]; then echo "Error: L2.exe not found at $SYSTEM_DIR" >&2; echo "Run setup.sh first." >&2; exit 1; fi
cd "$SYSTEM_DIR"
WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine L2.exe
LAUNCH
chmod +x "$INSTALL_DIR/play.sh"

info "Setup complete!"
info "Register an account at: $REGISTER_URL"
info "Launch the game with:   $INSTALL_DIR/play.sh"
