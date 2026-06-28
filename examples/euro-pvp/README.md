# EURO-PVP.COM Example

Automated setup and launch scripts for the **EURO-PVP.COM** Lineage 2 **Interlude
craft-PvP** private server on Linux (Wine 9.0, Ubuntu 24.04).

EURO-PVP runs **two Interlude servers off one client** — a mid-rate **x100** and a
high-rate **x1200**. You install the client once and pick the server you want on
the in-game server-selection screen.

## Quick Start

```bash
# 1. Install deps (one-time)
sudo apt install wine python3 p7zip-full p7zip-rar wget megatools

# 2. Run setup (downloads the full Interlude client + Ver.31 patch — several GB)
./setup.sh

# 3. Register an account at https://euro-pvp.com/ (Register / Account panel)

# 4. Launch the game and choose Interlude x100 or x1200 on the server list
./play.sh
```

## What setup.sh Does

1. Downloads the Interlude client from MEGA (falls back to the direct `files-europvp.com`
   mirror; prints manual instructions if both fail — the website itself is behind
   Cloudflare and 403s scripts).
2. Extracts it into `./client/` so that `client/system/L2.exe` exists.
3. Downloads and applies the **latest patch (Ver.31, 17.06.2026)** over the client.
4. Creates a 32-bit Wine prefix at `~/.wine-europvp`.
5. Downloads and runs the **file-validation launcher** (`Updater_Euro-PvP.com.exe`)
   to verify/repair files.
6. Generates a `play.sh` launch script.

Downloads use `megadl` (from the `megatools` package) because the MEGA links carry
the full decryption key — that avoids the Cloudflare-protected site and Google
Drive confirm-token handling. If MEGA is down, setup falls back to the direct HTTP
mirrors, and if those fail too it prints exact manual-download instructions and the
official page (`https://euro-pvp.com/download`) rather than failing silently.

## Server Details

| Property        | x100 server                  | x1200 server                 |
|-----------------|------------------------------|------------------------------|
| Chronicle       | Interlude                    | Interlude                    |
| Platform        | L2J (Java)                   | L2J (Java)                   |
| EXP / SP        | x100 / x100                  | x1200 / x1200                |
| Adena           | x1                           | x3000                        |
| Drop            | x5                           | x5                           |
| Safe / Max enchant | +3 / +16                  | +3 / +16                     |
| Style           | craft-PvP                    | craft-PvP                    |

| Property         | Value |
|------------------|-------|
| Server group     | EURO-PVP.COM (Interlude x100 + x1200) |
| Connection       | Baked into `client/system/L2.ini`; server chosen on the in-game list |
| Anticheat        | File-validation launcher (`Updater_Euro-PvP.com.exe`) + user-mode SmartGuard antibot — **no kernel-mode driver** |
| Latest patch     | Ver.31 (17.06.2026) |
| Website          | https://euro-pvp.com/ |
| Download page    | https://euro-pvp.com/download |
| Account register | https://euro-pvp.com/ (Register / Account panel) |

## Anticheat / Wine Compatibility

**No kernel-mode anticheat** — so there is no Wine-blocking ring-0 driver (unlike
Vanguard, kernel BattlEye/EAC). Protection is:

- A **file-validation launcher** (`Updater_Euro-PvP.com.exe`) that checks/repairs the
  client files. It runs fine under Wine; `setup.sh` runs it once for you.
- **SmartGuard** antibot, which is a **user-mode** client/server packet-encryption layer
  (no kernel driver). It is not a hard Wine blocker; in the rare case it complains,
  see the Wine notes below.

## Wine Notes

- 32-bit prefix (`WINEARCH=win32`) at `~/.wine-europvp` — Interlude is a 32-bit game.
- Recommended winetricks into that prefix if textures/UI or the launcher misbehave:
  ```bash
  WINEPREFIX="$HOME/.wine-europvp" winetricks -q d3dx9 corefonts vcrun2019
  ```
  - `d3dx9` — DirectX 9 runtime the client renders with.
  - `corefonts` — proper in-game/UI fonts.
  - `vcrun2019` — VC++ runtime the .NET-ish launcher often needs.
- Wine 9.0 has CSMT enabled by default (smoother rendering); no manual toggle needed.
- If the client opens a black window, set it to run windowed/borderless via the
  in-game `Options` or run `winecfg` and add a virtual desktop for the `~/.wine-europvp`
  prefix.
- `WINEDEBUG="-all"` is set in `play.sh` to silence Wine spam.
- The RAR archives need RAR support in 7-Zip: `p7zip-rar` (or install `unrar`).
