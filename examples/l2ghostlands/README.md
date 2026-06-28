# L2Ghostlands Example

Automated setup and launch scripts for the **L2Ghostlands** Interlude x4 private
server on Linux (Wine 9.0, Ubuntu 24.04).

L2Ghostlands is the **permanent, 24/7** server (launched 12 Jan 2024) and is the
sibling of the seasonal **GhostSeason x5**. Both share the same "Ghost"
pre-installed client and the same Wine prefix (`~/.wine-l2ghost`), so if you
already set up GhostSeason the prefix is reused.

## Quick Start

```bash
# 1. Run the setup script (downloads ~2.4 GB, extracts to ~6.4 GB)
./setup.sh

# 2. Register an account at https://l2ghostlands.com/accounts.php

# 3. Launch the game
./play.sh
```

## What setup.sh Does

1. Downloads the pre-installed client from **MediaFire** (robust link resolver),
   automatically falling back to **MEGA** (`megadl`) if MediaFire fails. If both
   fail, it prints manual-download instructions and exits cleanly.
2. Extracts the archive and normalises it into `./client/` (so
   `client/system/L2.exe` exists).
3. Creates a 32-bit Wine prefix at `~/.wine-l2ghost` (shared with GhostSeason).
4. Runs the bundled `L2GhostUpdater.exe` to fetch any patches (if it ships).
5. Generates a `play.sh` launch script pointing at the right prefix.

The server connection (IP + ports) is **baked into the client's `system/L2.ini`**,
so there is nothing to configure by hand — just register and play.

## Server Details

| Property    | Value |
|-------------|-------|
| Server      | L2Ghostlands (Interlude x4, permanent / 24/7) |
| Chronicle   | Interlude (C6) |
| Rates       | XP x4 · SP x4 · Adena x4 · Drop x4 · Spoil x4 · Seal Stones x4 |
| Enchant     | Safe +3 (full +6 weapon / +4 armor), max +16 weapon / +12 armor |
| Hosting     | Germany |
| Address     | Baked into `client/system/L2.ini` (not publicly listed; default L2 login 2106 / game 7777) |
| Anticheat   | None — no GameGuard / no kernel-mode driver (Wine-safe) |
| Website     | https://l2ghostlands.com |
| Register    | https://l2ghostlands.com/accounts.php |

## Client Download Mirrors

If the automated download fails, grab the pre-installed client manually and drop
the `.7z` into your install dir (default `~/l2ghostlands`), then re-run `./setup.sh`:

- **MediaFire:** https://www.mediafire.com/file/tlg1xmr523cuuiz/Lineage_II_Interlude_Ghostlands_Client_[pre-installed].7z/file
- **MEGA:** https://mega.nz/file/qplmnCDD#rHvF0tEVGGpf_xmDFlDFQWJwgI6O014bbbUhlVtZwuw
- **Standalone updater (MEGA):** https://mega.nz/file/ewUyCLDA#IgiyBiTt4BkY_j_3ALOVfiKQsqXArs_zjuNoke9jDo4

For the MEGA fallback you need `megatools`: `sudo apt install megatools`.

## Wine Notes

- This is a vanilla **Interlude** client with **no anticheat** (no GameGuard, no
  kernel driver), so it runs under plain Wine with no anti-cheat workarounds.
- The prefix must be **32-bit** (`WINEARCH=win32`); `setup.sh` creates it that way.
- If text/menus render with boxes or missing glyphs, install fonts:
  `WINEPREFIX=~/.wine-l2ghost winetricks corefonts`.
- If you see a black screen, flicker, or a crash at the login screen, the usual
  fixes are: install DirectX bits (`winetricks d3dx9`), toggle CSMT
  (`WINEPREFIX=~/.wine-l2ghost winetricks csmt=off`), or run windowed/virtual
  desktop (`winetricks vd=1280x720`). In `system/l2.ini` you can also force
  windowed mode.
- Setting the prefix to Windows XP/7 (`winecfg`) can help if the client refuses
  to start on the default Windows 10 setting.
