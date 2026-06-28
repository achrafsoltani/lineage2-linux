#!/bin/bash
# L2Warland (Legacy) — launch. Note: the "system" folder is named l2warland/ (not system/).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYS="$SCRIPT_DIR/l2warland"
WINEPREFIX="$HOME/.wine-l2warland"
if [ ! -f "$SYS/l2.exe" ]; then echo "Error: l2.exe not found at $SYS — run setup.sh first." >&2; exit 1; fi
cd "$SYS"
WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine l2.exe
