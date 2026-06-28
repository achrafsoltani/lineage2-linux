#!/bin/bash
# Lineage2.MS — launch script
# Starts the game client under Wine.
#
# Usage: ./play.sh
#
# Expects the following layout relative to this script:
#   ./client/system/L2.exe

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
