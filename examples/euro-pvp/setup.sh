#!/bin/bash
# EURO-PVP.COM (Interlude craft-PvP, x100 + x1200) — automated setup script
# Downloads the Interlude client + latest patch (Ver.31), extracts them,
# creates a 32-bit Wine prefix, runs the file-validation launcher, and
# writes play.sh.
#
# Usage: ./setup.sh [install_dir]
#   install_dir  Where to install (default: ~/euro-pvp)

set -euo pipefail

INSTALL_DIR="${1:-$HOME/Documents/Games/lineage2/euro-pvp}"
WINEPREFIX="$HOME/.wine-europvp"

# --- download sources (from https://euro-pvp.com/download) ---
DOWNLOAD_PAGE="https://euro-pvp.com/download"
# Full Interlude RU/EN client
CLIENT_MEGA="https://mega.nz/file/fQgDkQAL#erA_J1YG3FD1mL9DmRQ7r0GZtQutS1zuU7tV9RRvzEU"
CLIENT_HTTP="https://files-europvp.com/Euro-PVP_Client_ru_en.rar"
# Latest patch (Ver.31, 17.06.2026)
PATCH_MEGA="https://mega.nz/file/KNpGiDKB#RBhBZpBtpkx4nc9lxuQOj2avjwQFLlEDzrdRc3JR66g"
PATCH_HTTP="https://files-europvp.com/Patch_Euro-PVP.ru_v31_RU_EN.rar"
PATCH_HTTP2="https://europvp-files.com/Patch_Euro-PVP.ru_v31_RU_EN.rar"
# File-validation launcher / updater (NOT a kernel anticheat — just checks files)
UPDATER_URL="https://europvp-files.com/updater/Updater_Euro-PvP.com.exe"

CLIENT_ARCHIVE="Euro-PVP_Client.rar"
PATCH_ARCHIVE="Euro-PVP_Patch_v31.rar"

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; exit 1; }

# --- dependency check ---
# megadl (from the 'megatools' package) is used for the MEGA mirrors, which
# carry the full decryption key in the URL and avoid the Cloudflare-protected
# website and Google Drive confirm-token dance.
for cmd in wine python3 7z wget megadl; do
    command -v "$cmd" >/dev/null 2>&1 || \
        error "Missing dependency: $cmd  (MEGA downloads need 'megadl': sudo apt install megatools)"
done

manual_exit() {
    error "Automatic download failed (host may be behind Cloudflare or rate-limited).
Download these manually from $DOWNLOAD_PAGE and drop them in $INSTALL_DIR, then re-run setup.sh:
  Client : $CLIENT_HTTP
           (or MEGA: $CLIENT_MEGA)   -> save as $CLIENT_ARCHIVE
  Patch  : $PATCH_HTTP
           (or MEGA: $PATCH_MEGA)    -> save as $PATCH_ARCHIVE"
}

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# --- download + extract client ---
if [ -d "client/system" ]; then
    info "Client already extracted, skipping client download."
else
    if [ ! -f "$CLIENT_ARCHIVE" ]; then
        info "Downloading Interlude client (several GB) from MEGA..."
        megadl --path="$CLIENT_ARCHIVE" "$CLIENT_MEGA" || {
            warn "MEGA download failed, trying the direct mirror..."
            wget -O "$CLIENT_ARCHIVE" "$CLIENT_HTTP" || { rm -f "$CLIENT_ARCHIVE"; manual_exit; }
        }
    else
        info "Client archive already present."
    fi

    info "Extracting client (this can take a while)..."
    rm -rf _client_tmp && mkdir _client_tmp
    7z x -y "$CLIENT_ARCHIVE" -o_client_tmp >/dev/null || \
        error "Extraction failed. Your 7z may lack RAR support: sudo apt install p7zip-full p7zip-rar  (or: sudo apt install unrar && unrar x '$CLIENT_ARCHIVE')"

    # normalise into ./client so that client/system/L2.exe exists
    SYS_DIR="$(find _client_tmp -maxdepth 4 -type d -iname system | head -1)"
    [ -n "$SYS_DIR" ] || error "Could not locate a 'system' folder inside the client archive."
    ROOT="$(dirname "$SYS_DIR")"
    if [ "$ROOT" = "_client_tmp" ]; then
        mkdir -p client && cp -a _client_tmp/. client/
    else
        mv "$ROOT" client
    fi
    rm -rf _client_tmp "$CLIENT_ARCHIVE"
    info "Client ready at ./client"
fi

# --- download + apply latest patch (Ver.31) ---
if [ -f "client/.patch_v31_applied" ]; then
    info "Patch Ver.31 already applied, skipping."
else
    if [ ! -f "$PATCH_ARCHIVE" ]; then
        info "Downloading latest patch (Ver.31) from MEGA..."
        megadl --path="$PATCH_ARCHIVE" "$PATCH_MEGA" || {
            warn "MEGA patch download failed, trying direct mirrors..."
            wget -O "$PATCH_ARCHIVE" "$PATCH_HTTP" || wget -O "$PATCH_ARCHIVE" "$PATCH_HTTP2" || {
                rm -f "$PATCH_ARCHIVE"
                warn "Patch download failed — the in-game launcher will fetch it on first run instead."
            }
        }
    fi
    if [ -f "$PATCH_ARCHIVE" ]; then
        info "Applying patch over ./client ..."
        rm -rf _patch_tmp && mkdir _patch_tmp
        7z x -y "$PATCH_ARCHIVE" -o_patch_tmp >/dev/null || \
            error "Patch extraction failed (need RAR support in 7z: sudo apt install p7zip-rar)."
        # patch may ship system/ at its root, or inside a wrapper folder
        PSYS="$(find _patch_tmp -maxdepth 4 -type d -iname system | head -1)"
        if [ -n "$PSYS" ]; then PSRC="$(dirname "$PSYS")"; else PSRC="_patch_tmp"; fi
        cp -a "$PSRC"/. client/
        rm -rf _patch_tmp "$PATCH_ARCHIVE"
        touch "client/.patch_v31_applied"
        info "Patch Ver.31 applied."
    fi
fi

# --- wine prefix ---
if [ -d "$WINEPREFIX" ]; then
    info "Wine prefix already exists at $WINEPREFIX"
else
    info "Creating 32-bit Wine prefix at $WINEPREFIX..."
    WINEPREFIX="$WINEPREFIX" WINEARCH=win32 wineboot --init 2>/dev/null
    info "Wine prefix created."
fi

# --- file-validation launcher (validates/repairs files; not a kernel anticheat) ---
info "Downloading the file-validation launcher..."
if wget -q -O client/Updater_Euro-PvP.com.exe "$UPDATER_URL"; then
    info "Running launcher to validate files (close its window when it finishes)..."
    cd client
    WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine Updater_Euro-PvP.com.exe || true
    cd "$INSTALL_DIR"
else
    warn "Could not download the launcher. The client will still run; you can validate later."
fi

# --- launch script ---
LAUNCH_SCRIPT="$INSTALL_DIR/play.sh"
cat > "$LAUNCH_SCRIPT" <<'EOF'
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$SCRIPT_DIR/client/system"
WINEPREFIX="$HOME/.wine-europvp"
if [ ! -f "$SYSTEM_DIR/L2.exe" ]; then echo "Error: L2.exe not found at $SYSTEM_DIR" >&2; echo "Run setup.sh first." >&2; exit 1; fi
cd "$SYSTEM_DIR"
WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine L2.exe
EOF
chmod +x "$LAUNCH_SCRIPT"

info ""
info "Setup complete!"
info "Register an account at: https://euro-pvp.com/  (Register / Account panel)"
info "Pick a server in-game: Interlude x100 OR Interlude x1200."
info "Launch the game with: $LAUNCH_SCRIPT"
