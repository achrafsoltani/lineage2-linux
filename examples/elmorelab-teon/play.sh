#!/bin/bash
# ElmoreLab TEON — launch script
# Starts the game client under Wine.
#
# Usage: ./play.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="${1:-$HOME/L2ElmoreTeon}"
SYSTEM_DIR="$INSTALL_DIR/system"
WINEPREFIX="$HOME/.wine-l2teon"

if [ ! -f "$SYSTEM_DIR/L2.exe" ]; then
    echo "Error: L2.exe not found at $SYSTEM_DIR" >&2
    echo "Run setup.sh first." >&2
    exit 1
fi

cd "$SYSTEM_DIR"
WINEPREFIX="$WINEPREFIX" WINEDEBUG="-all" wine L2.exe
