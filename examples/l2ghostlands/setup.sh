#!/bin/bash
# L2Ghostlands — automated setup script
# Interlude x4 PERMANENT server (24/7); sibling of the seasonal GhostSeason.
# Shares the "Ghost" pre-installed client and Wine prefix (~/.wine-l2ghost).
#
# Downloads the pre-installed client (MediaFire, with MEGA fallback), extracts
# it, creates a 32-bit Wine prefix, runs the updater, and writes a play.sh.
#
# Usage: ./setup.sh [install_dir]
#   install_dir  Where to install (default: ~/l2ghostlands)

set -euo pipefail

INSTALL_DIR="${1:-$HOME/Documents/Games/lineage2/l2ghostlands}"
WINEPREFIX="$HOME/.wine-l2ghost"

# Pre-installed client mirrors (verified live). MediaFire is primary; MEGA is fallback.
MEDIAFIRE_PAGE='https://www.mediafire.com/file/tlg1xmr523cuuiz/Lineage_II_Interlude_Ghostlands_Client_[pre-installed].7z/file'
MEGA_CLIENT='https://mega.nz/file/qplmnCDD#rHvF0tEVGGpf_xmDFlDFQWJwgI6O014bbbUhlVtZwuw'
MEGA_UPDATER='https://mega.nz/file/ewUyCLDA#IgiyBiTt4BkY_j_3ALOVfiKQsqXArs_zjuNoke9jDo4'

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; exit 1; }

# --- dependency check (required) ---
for cmd in wine python3 7z wget; do
    command -v "$cmd" >/dev/null 2>&1 || error "Missing dependency: $cmd"
done

# megatools is only needed for the MEGA fallback; warn if absent (not fatal).
HAVE_MEGA=0
if command -v megadl >/dev/null 2>&1 || command -v megatools >/dev/null 2>&1; then
    HAVE_MEGA=1
else
    warn "megatools not found — MEGA fallback disabled. Install with: sudo apt install megatools"
fi

mega_dl() { # $1 = mega url  (downloads into the current directory)
    if command -v megadl >/dev/null 2>&1; then
        megadl "$1"
    else
        megatools dl "$1"
    fi
}

# --- download + extract ---
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [ -d "client/system" ] && [ -f "client/system/L2.exe" ]; then
    info "Client already extracted, skipping download."
else
    # Reuse any archive that is already present (e.g. a resumed download).
    ARCHIVE_FILE="$(ls -1 ./*.7z 2>/dev/null | head -n1 || true)"

    if [ -z "$ARCHIVE_FILE" ]; then
        GOT=0

        # ---- primary: MediaFire (robust resolver) ----
        info "Resolving MediaFire download link..."
        set +e
        DIRECT_URL="$(MEDIAFIRE_PAGE="$MEDIAFIRE_PAGE" python3 - <<'PY'
import os, re, base64, urllib.request
url = os.environ["MEDIAFIRE_PAGE"]
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64)"})
try:
    html = urllib.request.urlopen(req, timeout=60).read().decode("utf-8", "ignore")
except Exception:
    raise SystemExit(0)
direct = ""
# Current MediaFire pages hide the link in a base64 'data-scrambled-url' attribute.
m = re.search(r'data-scrambled-url="([^"]+)"', html)
if m:
    try:
        direct = base64.b64decode(m.group(1)).decode("utf-8", "ignore")
    except Exception:
        direct = ""
# Fallback: a plain href pointing at a download* host.
if not direct.startswith("http"):
    m = re.search(r'href="(https?://download[^"]+)"', html)
    if m:
        direct = m.group(1)
print(direct if direct.startswith("http") else "")
PY
)"
        set -e

        if [ -n "$DIRECT_URL" ]; then
            info "Downloading pre-installed client from MediaFire (~2.4 GB)..."
            if wget -c -O "GhostlandsClient.7z" "$DIRECT_URL"; then
                GOT=1
                ARCHIVE_FILE="GhostlandsClient.7z"
            else
                warn "MediaFire download failed."
                rm -f "GhostlandsClient.7z"
            fi
        else
            warn "Could not resolve the MediaFire direct link."
        fi

        # ---- fallback: MEGA ----
        if [ "$GOT" -ne 1 ] && [ "$HAVE_MEGA" -eq 1 ]; then
            info "Falling back to MEGA download (~2.4 GB)..."
            if mega_dl "$MEGA_CLIENT"; then
                ARCHIVE_FILE="$(ls -1 ./*.7z 2>/dev/null | head -n1 || true)"
                [ -n "$ARCHIVE_FILE" ] && GOT=1
            else
                warn "MEGA download failed."
            fi
        fi

        # ---- give up gracefully with manual instructions ----
        if [ "$GOT" -ne 1 ] || [ -z "$ARCHIVE_FILE" ]; then
            error "Automated download failed. Download the pre-installed client manually:
  MediaFire: $MEDIAFIRE_PAGE
  MEGA:      $MEGA_CLIENT
Save the .7z file into: $INSTALL_DIR
Then re-run: ./setup.sh"
        fi
    else
        info "Found existing archive: $ARCHIVE_FILE"
    fi

    info "Extracting $ARCHIVE_FILE ..."
    7z x -y "$ARCHIVE_FILE"

    # Normalise the extracted tree into ./client so that client/system/L2.exe exists.
    if [ -d "Lineage II Interlude Ghostlands Client [pre-installed]/Lineage II" ]; then
        mv "Lineage II Interlude Ghostlands Client [pre-installed]/Lineage II" client
        rm -rf "Lineage II Interlude Ghostlands Client [pre-installed]"
    else
        # Robust fallback: locate the folder that contains system/L2.exe
        SYS_EXE="$(find . -type f -iname 'L2.exe' 2>/dev/null | grep -iE '/system/L2\.exe$' | head -n1 || true)"
        [ -n "$SYS_EXE" ] || error "Could not find system/L2.exe after extraction."
        CLIENT_ROOT="$(dirname "$(dirname "$SYS_EXE")")"
        if [ "$CLIENT_ROOT" != "./client" ]; then
            mv "$CLIENT_ROOT" client
        fi
    fi

    [ -f "client/system/L2.exe" ] || error "client/system/L2.exe missing after extraction."
    rm -f ./*.7z
    info "Extracted and cleaned up."
fi

# --- wine prefix (32-bit, shared with GhostSeason) ---
if [ -d "$WINEPREFIX" ]; then
    info "Wine prefix already exists at $WINEPREFIX"
else
    info "Creating 32-bit Wine prefix at $WINEPREFIX..."
    WINEPREFIX="$WINEPREFIX" WINEARCH=win32 wineboot --init 2>/dev/null
    info "Wine prefix created."
fi

# --- updater (runs only if the client ships one) ---
UPDATER=""
for cand in "client/L2GhostUpdater.exe" "client/Updater.exe" "client/system/L2GhostUpdater.exe" "client/system/Updater.exe"; do
    if [ -f "$cand" ]; then UPDATER="$cand"; break; fi
done
if [ -n "$UPDATER" ]; then
    info "Running updater ($UPDATER) — close the window when it finishes..."
    ( cd "$(dirname "$UPDATER")" && WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine "./$(basename "$UPDATER")" ) || true
else
    warn "No updater found in the client; skipping. (Standalone updater: $MEGA_UPDATER)"
fi

# --- launch script ---
LAUNCH_SCRIPT="$INSTALL_DIR/play.sh"
cat > "$LAUNCH_SCRIPT" <<'LAUNCH'
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$SCRIPT_DIR/client/system"
WINEPREFIX="$HOME/.wine-l2ghost"
if [ ! -f "$SYSTEM_DIR/L2.exe" ]; then
    echo "Error: L2.exe not found at $SYSTEM_DIR" >&2
    echo "Run setup.sh first." >&2
    exit 1
fi
cd "$SYSTEM_DIR"
WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine L2.exe
LAUNCH
chmod +x "$LAUNCH_SCRIPT"

info "Setup complete!"
info "Register an account at: https://l2ghostlands.com/accounts.php"
info "Launch the game with:   $LAUNCH_SCRIPT"
