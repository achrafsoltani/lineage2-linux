#!/bin/bash
# ElmoreLab Erica (Interlude x3) — launch script
# Expects ./client/system/L2.exe relative to this script (run setup.sh first).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$SCRIPT_DIR/client/system"
WINEPREFIX="$HOME/.wine-l2erica"

if [ ! -f "$SYSTEM_DIR/L2.exe" ]; then
    echo "Error: L2.exe not found at $SYSTEM_DIR" >&2
    echo "Run setup.sh first." >&2
    exit 1
fi

cd "$SYSTEM_DIR"
WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine L2.exe
