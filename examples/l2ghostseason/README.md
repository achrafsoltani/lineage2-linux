# L2GhostSeason Example

Automated setup and launch scripts for the L2GhostSeason Interlude private server on Linux.

## Quick Start

```bash
# 1. Run the setup script (downloads ~2.4 GB, extracts ~6.4 GB)
./setup.sh

# 2. Register at https://l2ghostseason.com/accounts.php

# 3. Launch the game
./play.sh
```

## What setup.sh Does

1. Downloads the pre-installed client from MediaFire
2. Extracts it to `./client/`
3. Creates a 32-bit Wine prefix at `~/.wine-l2ghost`
4. Runs the GhostSeason updater to fetch any patches
5. Generates a `play.sh` launch script

## Server Details

| Property | Value |
|----------|-------|
| Server | L2GhostSeason (x5 Interlude) |
| Address | 158.220.114.136 |
| Auth port | 2106 |
| Game port | 7777 |
| Anticheat | None |
| Website | https://l2ghostseason.com |
