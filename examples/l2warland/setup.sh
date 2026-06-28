#!/bin/bash
# L2Warland "Legacy" — Interlude+ (Classic Interlude).  ⚠️ NOT Wine/Proton-playable — see README.md.
#
# This script only EXTRACTS THE CLIENT and builds a prefix. The client renders, but you CANNOT log in:
# Warland uses token auto-login (GL2UseTokenAutoLogin), so the token must come from WarlandLauncher.exe
# — a 64-bit .NET 4.8 + WebView2 launcher that does NOT run on Wine, Proton 9.0, or GE-Proton11 (tested).
# Running l2.exe directly (play.sh) reaches the login screen and then HANGS at "Logging in…" forever.
# Kept as a documented dead-end + because the stability research still ranks Warland #1 (just unrunnable).
# Anticheat is fine (server-side ZeusGuard; bundled GameGuard.exe/npkcrypt.dll are vestigial) — the wall
# is the launcher, not the anticheat.
#
# Gotchas this script handles:
#  - The official client zip is PASSWORD-PROTECTED. Password: warlandlegacy
#  - 7z extracts it (AES); plain `unzip` can't. (And `unzip`/`unar` already failed earlier.)
#  - The "system" folder is named `l2warland/` (not `system/`).
#  - REQUIRES the `winbind` package (L2 NTLM auth) — without it the client won't even render.
#
# Usage: ./setup.sh [install_dir]      (default: ~/Documents/Games/lineage2/l2warland)
#   Put the official downloads in ~/Downloads first (from l2warland.com):
#     Warland-Legacy-Client.zip   and   L2Warland-Patch.zip
set -euo pipefail

INSTALL_DIR="${1:-$HOME/Documents/Games/lineage2/l2warland}"
WINEPREFIX="$HOME/.wine-l2warland"
PW="warlandlegacy"
CLIENT="${WARLAND_CLIENT:-$HOME/Downloads/Warland-Legacy-Client.zip}"
PATCH="${WARLAND_PATCH:-$HOME/Downloads/L2Warland-Patch.zip}"

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; exit 1; }

for c in wine 7z; do command -v "$c" >/dev/null || error "Missing: $c"; done
command -v ntlm_auth >/dev/null || error "Missing winbind (ntlm_auth) — sudo apt install winbind (required for L2 auth)"

mkdir -p "$INSTALL_DIR"; cd "$INSTALL_DIR"
if [ -f l2warland/l2.exe ]; then
    info "Client already extracted."
else
    [ -f "$CLIENT" ] || error "Client not found: $CLIENT — download 'Warland-Legacy-Client.zip' from l2warland.com (or set WARLAND_CLIENT=...)"
    info "Extracting client with password (7z, AES)…"
    7z x -y -p"$PW" "$CLIENT" >/dev/null || error "Client extraction failed (wrong password? expected: $PW)"
    if [ -f "$PATCH" ]; then info "Applying patch…"; 7z x -y -p"$PW" "$PATCH" >/dev/null || true; fi
    [ -f l2warland/l2.exe ] || error "l2.exe not found after extraction — check archive layout."
    info "Extracted to $INSTALL_DIR/l2warland"
fi

if [ -d "$WINEPREFIX" ]; then
    info "Wine prefix exists at $WINEPREFIX"
else
    info "Creating 32-bit Wine prefix at $WINEPREFIX…"
    WINEPREFIX="$WINEPREFIX" WINEARCH=win32 WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init 2>/dev/null
fi

cat > "$INSTALL_DIR/play.sh" <<'LAUNCH'
#!/bin/bash
set -euo pipefail
cd "$(cd "$(dirname "$0")" && pwd)/l2warland"
WINEPREFIX="$HOME/.wine-l2warland" WINEDEBUG="-all" wine l2.exe
LAUNCH
chmod +x "$INSTALL_DIR/play.sh"

info "Done. Register at https://cp.l2warland.com  then launch: $INSTALL_DIR/play.sh"
info "Pick the x12 'Origin' (no-wipe) world, or wait for the x20 mid-rate opening 16 Oct 2026."
info "If the window is black, add: WINEPREFIX=$WINEPREFIX winetricks -q corefonts vcrun2019 d3dx9"
