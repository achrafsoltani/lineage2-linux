#!/bin/bash
# Lineage 2 Scarlet — Istina x50 (Fafurion) — automated setup script
#
# Downloads the Fafurion game client + the Istina x50 server "system" patch,
# extracts and normalises them into ./client, creates a 32-bit Wine prefix, and
# applies the exact Wine tweaks from Scarlet's OFFICIAL Linux guide
# ("Play Lineage 2 on Linux using WineHQ and Lutris"):
#   - winetricks corefonts + Tahoma + d3dx9 (+ vcrun2008)
#   - disable Wine CSMT (registry DWORD) to avoid high CPU usage
# ...then writes play.sh.
#
# NOTE: This is NOT Interlude. Lineage 2 Scarlet runs Fafurion / Etina's Fate
# (Orfen) / Freya / Gracia Final servers. This script targets the flagship
# Istina x50 (Fafurion) server; see the README to point it at another server.
#
# Usage: ./setup.sh [install_dir]
#   install_dir  Where to install (default: ~/lineage2-scarlet)

set -euo pipefail

INSTALL_DIR="${1:-$HOME/Documents/Games/lineage2/lineage2-scarlet}"
WINEPREFIX="$HOME/.wine-l2scarlet"

# --- official download mirrors (all linked from istina.lineage2scarlet.com) ---
# 22 GB Fafurion game client. Primary = direct HTTP (resumable, no quota/token).
CLIENT_URL="https://clients.l2top.co/www.l2top.co_fafurion_client.rar"
CLIENT_URL_MIRROR="https://l2db.info/uploads/files/lineage2/clients/CLIENT_FUFARION_166P_EU_(28.06.2019).rar"
CLIENT_MEGA="https://mega.nz/#!AHA1EQgQ!cjt1DxvIh4CIFkuyqEGMLLmfOcZslfWfH-vWjCYhYrc"
CLIENT_GDRIVE="https://drive.google.com/uc?id=1yeYwrQEIcmAz5Ha1R05c3QgntRPy9y0V&export=download"
# 108 MB Istina x50 server System patch (sets the server address inside l2.ini).
PATCH_MEGA="https://mega.nz/file/IQFm2Y6Y#m4HwrZRlIaVzaIvld-6zBOEplkb_AUF-W2JR8CF70H8"

DOWNLOAD_PAGE="https://istina.lineage2scarlet.com/"

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; exit 1; }

# --- dependency check ---
for cmd in wine python3 7z wget winetricks megadl; do
    command -v "$cmd" >/dev/null 2>&1 || \
        error "Missing dependency: $cmd  (try: sudo apt install wine winetricks p7zip-full p7zip-rar unrar cabextract megatools wget)"
done

# extract a .rar/.zip/.7z archive into a destination dir
extract() {
    local file="$1" dest="$2"
    mkdir -p "$dest"
    case "${file,,}" in
        *.rar)
            if command -v unrar >/dev/null 2>&1; then
                unrar x -o+ "$file" "$dest/" >/dev/null
            else
                7z x -y -o"$dest" "$file" >/dev/null \
                    || error "Cannot extract '$file' (.rar). Install rar support: sudo apt install unrar p7zip-rar"
            fi ;;
        *)
            7z x -y -o"$dest" "$file" >/dev/null ;;
    esac
}

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# --- 1. game client ---------------------------------------------------------
if [ -d "client/system" ] || [ -d "client/System" ]; then
    info "Client already present, skipping client download."
else
    ARCHIVE="fafurion_client.rar"
    if [ ! -f "$ARCHIVE" ]; then
        info "Downloading Fafurion game client (~22 GB) — this takes a while..."
        if ! wget -c -O "$ARCHIVE" "$CLIENT_URL"; then
            warn "Primary mirror failed, trying l2db.info mirror..."
            wget -c -O "$ARCHIVE" "$CLIENT_URL_MIRROR" || {
                rm -f "$ARCHIVE"
                error "Automatic client download failed.
Download the 22 GB Fafurion client MANUALLY from any mirror (all linked from $DOWNLOAD_PAGE):
  - Direct: $CLIENT_URL
  - Direct: $CLIENT_URL_MIRROR
  - Mega:   $CLIENT_MEGA   (use: megadl '<url>')
  - GDrive: $CLIENT_GDRIVE   (use: gdown)
Save it as: $INSTALL_DIR/$ARCHIVE
then re-run: ./setup.sh"
            }
        fi
    else
        info "Client archive already downloaded."
    fi

    info "Extracting client (several minutes; needs ~25 GB free space)..."
    rm -rf client_extract
    extract "$ARCHIVE" client_extract

    # normalise: find the folder that contains a 'system' dir -> ./client
    SYSDIR="$(find client_extract -maxdepth 4 -type d -iname system | head -1 || true)"
    [ -n "$SYSDIR" ] || error "No 'system' folder found inside the client archive."
    CLIENTROOT="$(dirname "$SYSDIR")"
    mkdir -p client
    shopt -s dotglob
    mv "$CLIENTROOT"/* client/
    shopt -u dotglob
    rm -rf client_extract
    rm -f "$ARCHIVE"
    info "Client extracted to ./client"
fi

# force the system folder to lowercase 'system' (Linux is case-sensitive)
if [ -d client/System ] && [ ! -d client/system ]; then
    mv client/System client/system
fi
[ -d client/system ] || error "client/system not found after extraction."

# --- 2. Istina x50 system patch --------------------------------------------
if [ -f "client/system/.scarlet-patched" ]; then
    info "System patch already applied."
else
    info "Downloading Istina x50 system patch (~108 MB) from Mega..."
    rm -rf patch_extract && mkdir -p patch_extract
    ( cd patch_extract && megadl "$PATCH_MEGA" ) \
        || error "Patch download failed. Get it manually from $DOWNLOAD_PAGE and copy its System files into $INSTALL_DIR/client/system"
    PATCH_FILE="$(find patch_extract -maxdepth 1 -type f | head -1 || true)"
    [ -n "$PATCH_FILE" ] || error "Patch archive not found after download."
    extract "$PATCH_FILE" patch_extract/unpacked
    # copy the patch's 'system' contents over client/system (replace mode)
    PATCH_SYS="$(find patch_extract/unpacked -type d -iname system | head -1 || true)"
    if [ -n "$PATCH_SYS" ]; then
        cp -rf "$PATCH_SYS"/. client/system/
    else
        # patch may be a bare set of files -> drop them straight into system
        cp -rf patch_extract/unpacked/. client/system/
    fi
    rm -rf patch_extract
    touch "client/system/.scarlet-patched"
    info "System patch applied to client/system"
fi

# ensure an 'L2.exe' exists (client/patch ship lowercase l2.exe; Linux is case-sensitive)
if [ ! -f "client/system/L2.exe" ]; then
    L2LOWER="$(find client/system -maxdepth 1 -iname 'l2.exe' | head -1 || true)"
    [ -n "$L2LOWER" ] && ln -sf "$(basename "$L2LOWER")" "client/system/L2.exe"
fi

# --- 3. wine prefix (32-bit) ------------------------------------------------
if [ -d "$WINEPREFIX" ]; then
    info "Wine prefix already exists at $WINEPREFIX"
else
    info "Creating 32-bit Wine prefix at $WINEPREFIX..."
    WINEPREFIX="$WINEPREFIX" WINEARCH=win32 wineboot --init 2>/dev/null
    info "Wine prefix created."
fi

# --- 4. Wine tweaks from Scarlet's OFFICIAL WineHQ/Lutris guide --------------
info "Installing recommended components (corefonts, Tahoma, d3dx9, vcrun2008)..."
WINEPREFIX="$WINEPREFIX" winetricks -q corefonts tahoma d3dx9 vcrun2008 \
    || warn "Some winetricks components failed — corefonts + d3dx9 are the important ones."
# msxml6 / dotnet are only needed by some .NET launchers; best-effort, never block.
WINEPREFIX="$WINEPREFIX" winetricks -q msxml6 >/dev/null 2>&1 || true

info "Disabling Wine CSMT (avoids high CPU usage — per the official guide)..."
WINEPREFIX="$WINEPREFIX" wine reg add 'HKCU\Software\Wine\Direct3D' /v csmt /t REG_DWORD /d 0 /f >/dev/null 2>&1 \
    || warn "Could not set CSMT key; set HKCU\\Software\\Wine\\Direct3D  csmt=dword:0  manually in regedit."

# --- 5. launch script -------------------------------------------------------
LAUNCH_SCRIPT="$INSTALL_DIR/play.sh"
cat > "$LAUNCH_SCRIPT" <<'EOF'
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$SCRIPT_DIR/client/system"
WINEPREFIX="$HOME/.wine-l2scarlet"
if [ ! -f "$SYSTEM_DIR/L2.exe" ]; then
    echo "Error: L2.exe not found at $SYSTEM_DIR" >&2
    echo "Run setup.sh first." >&2
    exit 1
fi
cd "$SYSTEM_DIR"
WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine L2.exe
EOF
chmod +x "$LAUNCH_SCRIPT"

info ""
info "Setup complete!"
info "No registration page needed — accounts AUTO-CREATE at the login screen:"
info "  just type a new username + password the first time you log in."
info ""
info "IMPORTANT (from Scarlet's official Linux guide) — set ONCE in your OS settings:"
info "  Remap ALT -> SUPER  (KDE: System Settings > Keyboard > shortcuts/modifiers;"
info "  GNOME: gnome-tweaks > Keyboard) so in-game ALT shortcuts work under Wine."
info ""
info "Launch the game with: $LAUNCH_SCRIPT"
