#!/bin/bash
# ElmoreLab "Median" (Interlude x2 Remastered) — automated setup script
#
# Downloads/extracts the ElmoreLab Median Interlude (L2OFF) client, creates a
# dedicated 32-bit Wine prefix, runs the Median Updater.exe to patch the client
# (and bake in the server connection), then writes a play.sh launcher.
#
# elmorelab.com sits behind Cloudflare and the Median download is gated behind
# your profile, so this script does NOT hard-code a MEGA link it cannot verify.
# Instead it either:
#   * downloads with `megadl` if you pass the MEGA link from your profile, OR
#   * uses an archive you already downloaded into the install dir, OR
#   * prints clear manual-download instructions and exits cleanly.
#
# Usage:
#   ./setup.sh [install_dir]
#   MEDIAN_MEGA_URL="https://mega.nz/file/XXXX#KEY" ./setup.sh [install_dir]
#   UPDATER_URL="https://elmorelab.com/files/updater_median/Updater.zip" ./setup.sh
#
#   install_dir   Where to install (default: ~/elmorelab-median)

set -euo pipefail

INSTALL_DIR="${1:-$HOME/Documents/Games/lineage2/elmorelab-median}"
WINEPREFIX="$HOME/.wine-l2median"

# --- official sources (verified live, mid-2026) ---
PROFILE_URL="https://profile.elmorelab.com/median_x2/profile"
SITE_URL="https://elmorelab.com/"

# --- optional, supplied by YOU (left empty on purpose — never invent a link) ---
MEDIAN_MEGA_URL="${MEDIAN_MEGA_URL:-}"   # MEGA client link copied from your profile
UPDATER_URL="${UPDATER_URL:-}"           # Median Updater.zip link (optional)

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; exit 1; }

manual_instructions() {
    cat >&2 <<EOF

--------------------------------------------------------------------------
 Manual download required — no client archive found
--------------------------------------------------------------------------
The ElmoreLab Median client is distributed behind Cloudflare/login, so this
script will not guess a download URL. Do ONE of the following, then re-run:

 1. Register / log in:   $PROFILE_URL
 2. From your profile (or $SITE_URL) download the Median Interlude client
    (MEGA / Google Drive mirror, ~3-4 GB) AND the Median Updater.

 Then EITHER:
   a) drop the downloaded client archive (*.7z or *.zip) into:
        $INSTALL_DIR
      and re-run:   ./setup.sh
   OR
   b) re-run with the MEGA link you copied from your profile:
        MEDIAN_MEGA_URL="https://mega.nz/file/XXXX#KEY" ./setup.sh

 If you also have the updater link, pass it too (optional):
        UPDATER_URL="https://elmorelab.com/files/updater_median/Updater.zip" \\
        MEDIAN_MEGA_URL="https://mega.nz/file/XXXX#KEY" ./setup.sh
--------------------------------------------------------------------------
EOF
}

# --- dependency check ---
for cmd in wine python3 7z wget unzip megadl; do
    command -v "$cmd" >/dev/null 2>&1 || \
        error "Missing dependency: $cmd (try: sudo apt install wine p7zip-full wget unzip megatools)"
done

# --- locate / download client ---
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [ -d "client/system" ] && [ -f "client/system/L2.exe" ]; then
    info "Client already extracted, skipping download."
else
    ARCHIVE=""
    if [ -n "$MEDIAN_MEGA_URL" ]; then
        ARCHIVE="ElmoreMedian.7z"
        if [ ! -f "$ARCHIVE" ]; then
            info "Downloading Median client from MEGA via megadl (~3-4 GB)..."
            megadl --path="$ARCHIVE" "$MEDIAN_MEGA_URL" \
                || error "megadl failed. Check the MEGA link, or download manually."
        else
            info "Archive already downloaded."
        fi
    else
        # Re-use an archive you already downloaded into INSTALL_DIR
        ARCHIVE="$(find . -maxdepth 1 -type f \( -iname '*.7z' -o -iname '*.zip' -o -iname '*.rar' \) | head -1 || true)"
        ARCHIVE="${ARCHIVE#./}"
    fi

    if [ -z "$ARCHIVE" ] || [ ! -f "$ARCHIVE" ]; then
        manual_instructions
        info "Nothing to extract yet — exiting cleanly. Follow the steps above, then re-run."
        exit 0
    fi

    info "Extracting $ARCHIVE (this may take a while)..."
    7z x -y "$ARCHIVE" >/dev/null

    # Normalise the layout so that ./client/system/L2.exe exists.
    if [ -d "client/system" ]; then
        :
    elif [ -d "system" ]; then
        mkdir -p client
        mv system client/
        for d in maps textures systextures animations sounds music staticmeshes voice movies guard; do
            [ -d "$d" ] && mv "$d" client/ 2>/dev/null || true
        done
    else
        SYS_PATH="$(find . -maxdepth 4 -type d -iname system | head -1 || true)"
        if [ -n "$SYS_PATH" ]; then
            CLIENT_ROOT="$(dirname "$SYS_PATH")"
            [ "$CLIENT_ROOT" = "./client" ] || mv "$CLIENT_ROOT" client
        else
            error "Could not find a 'system' folder inside the archive. Inspect contents in $INSTALL_DIR."
        fi
    fi

    rm -f "$ARCHIVE"
    info "Extracted to $INSTALL_DIR/client"
fi

# --- wine prefix (32-bit) ---
if [ -d "$WINEPREFIX" ]; then
    info "Wine prefix already exists at $WINEPREFIX"
else
    info "Creating 32-bit Wine prefix at $WINEPREFIX..."
    WINEPREFIX="$WINEPREFIX" WINEARCH=win32 wineboot --init 2>/dev/null
    info "Wine prefix created."
fi

# --- updater (patches the client to Median + writes the server connection) ---
run_updater() {
    local exe
    exe="$(find client -maxdepth 2 -type f -iname 'Updater*.exe' | head -1 || true)"
    if [ -n "$exe" ]; then
        info "Running Median updater ($exe) — let it finish (Full Check), then close it..."
        ( cd "$(dirname "$exe")" && WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine "./$(basename "$exe")" ) || true
        return 0
    fi
    return 1
}

if [ -n "$UPDATER_URL" ]; then
    info "Downloading Median updater..."
    if wget -q -O updater.zip "$UPDATER_URL"; then
        unzip -o updater.zip -d client/ >/dev/null 2>&1 || true
        rm -f updater.zip
    else
        warn "Could not download updater from UPDATER_URL."
    fi
fi

if ! run_updater; then
    warn "No Updater.exe found in the client."
    warn "Download the Median updater from your profile ($PROFILE_URL),"
    warn "place Updater.exe inside: $INSTALL_DIR/client/  then run it once:"
    warn "  ( cd \"$INSTALL_DIR/client\" && WINEPREFIX=\"$WINEPREFIX\" wine Updater.exe )"
fi

# --- launch script ---
LAUNCH_SCRIPT="$INSTALL_DIR/play.sh"
cat > "$LAUNCH_SCRIPT" <<'EOF'
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$SCRIPT_DIR/client/system"
WINEPREFIX="$HOME/.wine-l2median"
if [ ! -f "$SYSTEM_DIR/L2.exe" ]; then echo "Error: L2.exe not found at $SYSTEM_DIR" >&2; echo "Run setup.sh first." >&2; exit 1; fi
cd "$SYSTEM_DIR"
WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine L2.exe
EOF
chmod +x "$LAUNCH_SCRIPT"

info ""
info "Setup complete!"
info "Register / manage your account at: $PROFILE_URL"
info "Launch the game with: $LAUNCH_SCRIPT"
