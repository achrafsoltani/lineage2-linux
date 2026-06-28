#!/bin/bash
# Lineage2.MS (Interlude x10, "Luna" — Chronicle 6, no-wipe) — automated setup script
# Downloads the Interlude client + the required "MS Patch", extracts and patches
# them (deleting /system before applying the patch, as the server requires),
# creates a 32-bit Wine prefix, and writes play.sh.
#
# Lineage2.MS uses only a userspace client protection bundled in the MS Patch
# (packet encryption / anti-bot). There is NO kernel-mode anticheat driver, so
# the client runs under Wine.
#
# Usage: ./setup.sh [install_dir]
#   install_dir  Where to install (default: ~/lineage2ms)

set -euo pipefail

INSTALL_DIR="${1:-$HOME/Documents/Games/lineage2/lineage2ms}"
WINEPREFIX="$HOME/.wine-l2ms"

# --- official download mirrors (from https://lineage2.ms/en/start) ---
# Primary automated downloads use the MEGA mirrors via `megadl` (megatools).
CLIENT_MEGA="https://mega.nz/file/BTcljaKL#V1sGZh2eYVeT4rv4BzadEFcsOrIWXgSoEKVhgIarQ3k"
PATCH_MEGA="https://mega.nz/file/YeVmHYZA#xprKpbsmRNVqffU-Jeua97NKje0IiKrGIXYTad6kwwo"
# Alternate mirrors (for the manual fallback shown below if MEGA fails):
CLIENT_GDRIVE="https://drive.google.com/uc?export=download&id=1DOgwPmZDaaF2SnXy52LBbPEyAF2sjFz5"
CLIENT_MEDIAFIRE="https://www.mediafire.com/file_premium/njrg5ulrlbexgmu/Client_It_%5BMS_10.0%5D.zip/file"
PATCH_GDRIVE="https://drive.google.com/uc?export=download&id=1WH_WENquVJhkjSsqNZCZuDpEeA22sPsR"
PATCH_MEDIAFIRE="https://www.mediafire.com/file_premium/0p1mp07vt0waj8x/MS_Patch_2.3.zip/file"

CLIENT_ARCHIVE="L2MS_Client.zip"
PATCH_ARCHIVE="L2MS_Patch.zip"

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; exit 1; }

# --- dependency check ---
for cmd in wine python3 7z wget megadl; do
    command -v "$cmd" >/dev/null 2>&1 || \
        error "Missing dependency: $cmd (megadl comes from 'sudo apt install megatools')"
done

# --- locate the shallowest 'system' dir inside an extracted tree ---
find_system_parent() {
    # $1 = root dir to search; prints the directory that CONTAINS 'system'
    local sys
    sys=$(find "$1" -maxdepth 4 -type d -iname system -printf '%d\t%p\n' 2>/dev/null \
          | sort -n | head -1 | cut -f2-)
    [ -n "$sys" ] && dirname "$sys"
}

# --- manual fallback instructions ---
manual_fallback() {
    cat >&2 <<EOF

------------------------------------------------------------------
Automatic download failed. Please download the files MANUALLY from
the official page and drop them into:  $INSTALL_DIR

Official download page:  https://lineage2.ms/en/start

  Interlude client (~5 GB) -> save as: $INSTALL_DIR/$CLIENT_ARCHIVE
    MEGA      : $CLIENT_MEGA
    GoogleDrv : $CLIENT_GDRIVE
    MediaFire : $CLIENT_MEDIAFIRE

  MS Patch (REQUIRED) -> save as:        $INSTALL_DIR/$PATCH_ARCHIVE
    MEGA      : $PATCH_MEGA
    GoogleDrv : $PATCH_GDRIVE
    MediaFire : $PATCH_MEDIAFIRE

Then re-run:  ./setup.sh $INSTALL_DIR
------------------------------------------------------------------
EOF
}

# --- download + extract + patch ---
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if ls client/system/[lL]2.[eE][xX][eE] >/dev/null 2>&1; then
    info "Client already installed and patched, skipping download/extract."
else
    # 1. Client archive
    if [ ! -f "$CLIENT_ARCHIVE" ]; then
        info "Downloading Interlude client from MEGA (~5 GB; MEGA's free transfer is slow and rate-limited)..."
        if ! megadl --path="$CLIENT_ARCHIVE" "$CLIENT_MEGA"; then
            warn "MEGA client download failed (MEGA caps free transfers around 5 GB/day)."
            manual_fallback
            error "Client could not be downloaded automatically. See instructions above."
        fi
    else
        info "Client archive already present."
    fi

    # 2. MS Patch archive
    if [ ! -f "$PATCH_ARCHIVE" ]; then
        info "Downloading MS Patch from MEGA (required to connect)..."
        if ! megadl --path="$PATCH_ARCHIVE" "$PATCH_MEGA"; then
            warn "MEGA patch download failed."
            manual_fallback
            error "MS Patch could not be downloaded automatically. See instructions above."
        fi
    else
        info "MS Patch archive already present."
    fi

    # 3. Extract the client into ./client
    info "Extracting client (this takes a while)..."
    rm -rf _extract_client
    mkdir -p _extract_client
    7z x -y -o_extract_client "$CLIENT_ARCHIVE" >/dev/null
    CLIENT_ROOT=$(find_system_parent _extract_client)
    [ -n "$CLIENT_ROOT" ] || error "No 'system' folder found inside the client archive."
    rm -rf client
    mv "$CLIENT_ROOT" client
    rm -rf _extract_client

    # 4. Apply MS Patch. The server REQUIRES deleting /system before patching.
    info "Removing old /system and applying the MS Patch..."
    find client -maxdepth 1 -type d -iname system -exec rm -rf {} +
    rm -rf _extract_patch
    mkdir -p _extract_patch
    7z x -y -o_extract_patch "$PATCH_ARCHIVE" >/dev/null
    PATCH_ROOT=$(find_system_parent _extract_patch)
    [ -n "$PATCH_ROOT" ] || error "No 'system' folder found inside the MS Patch archive."
    cp -rf "$PATCH_ROOT"/. client/
    rm -rf _extract_patch

    # 5. Normalise the system folder name to lowercase 'system'
    SYS_FINAL=$(find client -maxdepth 1 -type d -iname system | head -1)
    [ -n "$SYS_FINAL" ] || error "Patched client is missing its 'system' folder."
    if [ "$(basename "$SYS_FINAL")" != "system" ]; then
        mv "$SYS_FINAL" client/system
    fi

    # 6. Verify L2.exe is present
    if ! ls client/system/[lL]2.[eE][xX][eE] >/dev/null 2>&1; then
        error "After patching, client/system/L2.exe is missing — the patch did not apply correctly."
    fi

    rm -f "$CLIENT_ARCHIVE" "$PATCH_ARCHIVE"
    info "Client extracted and patched into $INSTALL_DIR/client"
fi

# --- wine prefix ---
if [ -d "$WINEPREFIX" ]; then
    info "Wine prefix already exists at $WINEPREFIX"
else
    info "Creating 32-bit Wine prefix at $WINEPREFIX..."
    WINEPREFIX="$WINEPREFIX" WINEARCH=win32 wineboot --init 2>/dev/null
    info "Wine prefix created."
fi

# --- optional in-client launcher/updater (only if one shipped) ---
# Lineage2.MS updates are delivered as the MS Patch (applied above), so there is
# normally no in-client updater to run. If the client happens to ship one, run it
# once but never block setup on it.
UPDATER=$(find "$INSTALL_DIR/client" -maxdepth 2 -type f \
            \( -iname 'updater*.exe' -o -iname 'l2update*.exe' \) 2>/dev/null | head -1 || true)
if [ -n "${UPDATER:-}" ]; then
    info "Found an updater ($UPDATER) — running it (close the window when done)..."
    ( cd "$(dirname "$UPDATER")" && \
      WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine "$(basename "$UPDATER")" ) || true
fi

# --- launch script ---
LAUNCH_SCRIPT="$INSTALL_DIR/play.sh"
cat > "$LAUNCH_SCRIPT" <<'PLAY'
#!/bin/bash
# Lineage2.MS — launch script. Starts the client under Wine.
# Usage: ./play.sh   (expects ./client/system/L2.exe relative to this script)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$SCRIPT_DIR/client/system"
WINEPREFIX="$HOME/.wine-l2ms"

if [ ! -f "$SYSTEM_DIR/L2.exe" ] && [ ! -f "$SYSTEM_DIR/l2.exe" ]; then
    echo "Error: L2.exe not found at $SYSTEM_DIR" >&2
    echo "Run setup.sh first." >&2
    exit 1
fi

cd "$SYSTEM_DIR"
WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine L2.exe
PLAY
chmod +x "$LAUNCH_SCRIPT"

info ""
info "Setup complete!"
info "Register an account at: https://lineage2.ms/sign-up"
info "Launch the game with:   $LAUNCH_SCRIPT"
info "At the login screen pick your proxy region (UA/EU, KZ/ASIA, USA/BRASIL)."
