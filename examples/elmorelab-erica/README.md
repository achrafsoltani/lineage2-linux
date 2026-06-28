# ElmoreLab — Erica (Interlude x3)

Setup and launch scripts for **ElmoreLab's Erica x3 Interlude** server on Linux/Wine.
The best-populated Wine-compatible Interlude option in this repo (~5k online at launch).

## Quick Start

```bash
# 1. Register
#    https://profile.elmorelab.com/account/register

# 2. Download the Erica client (Google Drive / MEGA) from
#    https://elmorelab.com/servers/erica/download.html

# 3. Point setup.sh at your downloaded archive (it extracts, makes the Wine
#    prefix, runs the Updater, and writes play.sh):
ERICA_ARCHIVE="$HOME/Downloads/<the-file>.7z" ./setup.sh
#    (or drop the archive into ~/L2ElmoreErica and just run ./setup.sh)

# 4. Play
./play.sh
```

## What setup.sh does

1. Extracts the client archive you downloaded into `~/L2ElmoreErica/client/`
2. Creates a dedicated 32-bit Wine prefix at `~/.wine-l2erica`
3. Runs the ElmoreLab **Updater.exe** under Wine — click **Full Check** to patch the client and bake in the Erica server connection
4. Writes a `play.sh` launcher

## Server Details

| Property | Value |
|----------|-------|
| Server | ElmoreLab **Erica** (Interlude **x3**) |
| Launched | 22 May 2026 (registration opened 14 May 2026) |
| Population | ~5,000 online (healthy) |
| Box limit | 2 + 1 |
| Monetization | No P2W, no GM shops — stage-based progression |
| Anticheat | **Server-side CAPTCHA only — no kernel driver** |
| Wine | ✅ Compatible (Wine 9.0, 32-bit prefix) |
| Website | https://elmorelab.com/servers/erica/ |
| Register | https://profile.elmorelab.com/account/register |

## Wine notes

- No kernel-mode anticheat — Erica's anti-bot is an **in-game CAPTCHA** (a popup while gaining
  XP/Adena); it's just a normal client window and works under Wine. Respect the **2+1 box limit** —
  running extra clients via separate prefixes can trip server-side box/bot detection.
- L2OFF clients are picky about the exact build — use the **official Erica client + Updater**, don't
  substitute a random Interlude client.
- If the `.NET` Updater.exe misbehaves under Wine, re-run it, or grab a full/torrent client mirror
  from the download page. No winetricks/native DLLs are normally needed.
