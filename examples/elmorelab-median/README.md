# ElmoreLab Median Example

Automated setup and launch scripts for the **ElmoreLab "Median" (Interlude x2 Remastered)**
private server on Linux (Wine 9.0, Ubuntu 24.04).

Median is ElmoreLab's heavily reworked Interlude (C6) ruleset: reworked classes
and skills, a new buff system, a new Soul Crystal system, support-class and
balance reworks, plus Olympiad/armor upgrades. It is an **L2OFF** server with a
client patched by ElmoreLab's `Updater.exe`. There is **no kernel-mode
anticheat** — only a server-side CAPTCHA anti-bot — so it runs cleanly under Wine.

## Quick Start

```bash
# 0. Install deps (Ubuntu/Debian):
sudo apt install wine p7zip-full wget unzip megatools

# 1. Register / log in and grab the client + updater links from your profile:
#       https://profile.elmorelab.com/median_x2/profile

# 2a. Fully automated (pass the MEGA link you copied from your profile):
MEDIAN_MEGA_URL="https://mega.nz/file/XXXX#KEY" ./setup.sh

#  or 2b. Download the client archive yourself, drop the *.7z / *.zip into
#         ~/elmorelab-median/  and just run:
./setup.sh

# 3. Launch the game
./play.sh
```

If you run `./setup.sh` with no archive and no `MEDIAN_MEGA_URL`, it prints exact
manual-download instructions and exits cleanly (it never guesses a URL).

## What setup.sh Does

1. Checks dependencies (`wine python3 7z wget unzip megadl`).
2. Obtains the Median Interlude client, in this order:
   - downloads via `megadl` if you pass `MEDIAN_MEGA_URL=...`, or
   - uses an archive (`*.7z` / `*.zip` / `*.rar`) you already placed in the install dir, or
   - prints manual-download instructions and exits cleanly.
3. Extracts and normalises the layout so `client/system/L2.exe` exists.
4. Creates a dedicated 32-bit Wine prefix at `~/.wine-l2median`.
5. Runs the Median `Updater.exe` (do a **Full Check**) to patch the client and
   bake in the server connection. Optionally fetched via `UPDATER_URL=...`.
6. Writes a `play.sh` launcher into the install dir and `chmod +x` it.

## Dependencies

- `wine` (9.0+ recommended) with 32-bit support (`wine32`)
- `python3`
- `7z` (`p7zip-full`)
- `wget`, `unzip`
- `megatools` (provides `megadl`) — `sudo apt install megatools`

## Server Details

| Property    | Value |
|-------------|-------|
| Server      | ElmoreLab Median (Interlude x2 "Remastered") |
| Chronicle   | Interlude (C6), heavily reworked "Median" ruleset |
| Rates       | EXP/SP x2 (drop/adena/spoil set server-side — see profile/forum) |
| Connection  | Baked into the client `L2.ini` by the Median updater (not a public IP:port) |
| Anticheat   | **None client-side** — server-side CAPTCHA anti-bot + anti-exploit only |
| Client      | L2OFF Interlude client + `Updater.exe` (unsigned, user-mode) |
| Profile     | https://profile.elmorelab.com/median_x2/profile |
| Website     | https://elmorelab.com |
| Forum       | https://forum.elmorelab.com |
| Knowledge   | https://knowledgedb.elmorelab.com |

## Wine Notes

- **No kernel-mode anticheat.** Median's only anti-bot is a server-side CAPTCHA
  (an in-game pop-up that kicks AFK botters). The only client-side executable is
  an unsigned `Updater.exe` (user-mode) — Wine runs it fine. This is the key
  reason the server works on Linux: there is no `*.sys` driver to load.
- Use a **dedicated 32-bit prefix** (`WINEARCH=win32`) at `~/.wine-l2median`.
  The L2 client is a 32-bit app; mixing it into your default 64-bit prefix can
  cause crashes.
- **No winetricks or native DLL overrides are required** for a stock Interlude
  client. If you hit missing-font / black-text issues in menus, install fonts:
  `WINEPREFIX=~/.wine-l2median winetricks corefonts`.
- If the game starts in an awkward window mode, fullscreen vs windowed is set in
  `system/l2.ini` (`WindowedMode`). Editing it on Interlude clients requires the
  RSA-encrypted-ini tooling described in the repo root README (`l2ini.py`).
- `WINEDEBUG="-all"` (already set in `play.sh`) silences noisy Wine logs; remove
  it temporarily if you need to troubleshoot a crash.
- The unsigned updater may be flagged "RiskWare" by some AV — that is the
  missing Microsoft code-signature, not a kernel driver. Irrelevant on Linux.

## Troubleshooting

- **Cloudflare 403 when downloading:** the per-server download page is gated.
  Log in at the profile URL above, copy the MEGA link, and pass it via
  `MEDIAN_MEGA_URL=...`, or download in a browser and drop the archive into the
  install dir.
- **`megadl` fails / quota:** use the Google Drive mirror from your profile in a
  browser instead, then drop the archive in the install dir and re-run.
- **`L2.exe not found`:** the archive didn't contain a `system/` folder where
  expected — inspect the extracted files in the install dir and move the client
  folder to `client/` so that `client/system/L2.exe` exists.
- **Login works but the world won't load / wrong server:** re-run the
  `Updater.exe` and choose **Full Check** so the correct Median files and
  connection are written.
