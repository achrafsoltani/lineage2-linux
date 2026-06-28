# Lineage 2 Scarlet Example

Automated setup and launch scripts for the **Lineage 2 Scarlet** project on Linux,
targeting its flagship **Istina x50 (Fafurion)** server.

> **Not Interlude.** Lineage 2 Scarlet runs modern chronicles — Fafurion, Etina's
> Fate (Orfen), Freya and Gracia Final — across several servers. This example sets
> up the Istina x50 Fafurion server; the same flow works for the others by swapping
> the client mirror + system-patch URLs in `setup.sh` (see *Other servers* below).

Lineage 2 Scarlet is the showcase **Linux-friendly** example in this repo: the
operators publish their own official guide,
[*Play Lineage 2 on Linux using WineHQ and Lutris*](https://www.lineage2scarlet.com/lineage2-on-linux/),
and these scripts faithfully automate its recommended Wine tweaks.

## Quick Start

```bash
# 1. Install dependencies (Ubuntu 24.04)
sudo apt install wine winetricks p7zip-full p7zip-rar unrar cabextract megatools wget python3

# 2. Run setup (downloads ~22 GB client + ~108 MB patch; needs ~25 GB free)
./setup.sh

# 3. Launch the game
./play.sh

# 4. At the login screen, type ANY new username + password — the account
#    is created automatically on first login. There is no registration page.
```

## What `setup.sh` Does

1. **Downloads the Fafurion game client (~22 GB)** from the direct HTTP mirror
   linked on `istina.lineage2scarlet.com` (`clients.l2top.co`), with automatic
   fallback to the `l2db.info` mirror. If both fail it prints exact **manual
   download instructions** (Mega / Google Drive links + where to drop the file)
   and exits cleanly — it never invents a URL or fails silently.
2. **Extracts and normalises** the client into `./client/` so that
   `./client/system/L2.exe` exists (it also symlinks a lowercase `l2.exe` to
   `L2.exe` since Linux is case-sensitive).
3. **Downloads and applies the Istina x50 system patch (~108 MB)** from Mega
   (via `megadl`). This patch is what points the client at the Scarlet server —
   it overwrites the `system/` folder (l2.ini etc.).
4. **Creates a 32-bit Wine prefix** at `~/.wine-l2scarlet`.
5. **Applies the official guide's Wine tweaks** (see *Wine notes* below):
   `winetricks corefonts tahoma d3dx9 vcrun2008` and disables CSMT via the Wine
   registry.
6. **Generates `play.sh`** with the correct `WINEPREFIX`.

## Server Details

| Property        | Value |
|-----------------|-------|
| Project         | Lineage 2 Scarlet (`lineage2scarlet.com`) |
| Server          | Istina x50 — **Fafurion** chronicle (NOT Interlude) |
| Rates           | EXP/SP **50x**, Party EXP/SP 2x, Drop 1x, Spoil 10x, Adena 25x |
| Other servers   | Orfen 5x (Etina's Fate), Freya 15x, Legendary 20x (Gracia Final) |
| Connect details | Baked into the client `l2.ini` by the system patch — no manual entry |
| Ports           | Standard L2: auth `2106`, game `7777` |
| Accounts        | Auto-created at the login screen (no registration page) |
| Anticheat       | **No kernel-mode anticheat** — user-mode SmartGuard-class antibot only |
| Website         | https://istina.lineage2scarlet.com/ |
| Linux guide     | https://www.lineage2scarlet.com/lineage2-on-linux/ |

## Wine notes

Wine **9.0** with a **32-bit** prefix (`WINEARCH=win32`) works well. `setup.sh`
applies everything from Scarlet's official *Play Lineage 2 on Linux using WineHQ
and Lutris* guide:

- **winetricks `corefonts` + `tahoma`** — Lineage 2 needs Tahoma and the MS core
  fonts or the UI renders with missing/garbled text.
- **winetricks `d3dx9`** (the guide says "d3dx9 or above") — the client is
  DirectX 9.0c; the native D3DX9 redistributables avoid rendering glitches.
- **winetricks `vcrun2008`** — Visual C++ 2008 runtime the guide lists.
- *(Optional, best-effort)* `dotnet20` / `msxml6` — only needed by some .NET
  launchers; the script runs `msxml6` best-effort and never blocks on it.
- **Disable CSMT** — the guide says to create a DWORD in the Wine registry to
  turn off CSMT "to avoid High CPU usage". The script runs:
  ```
  wine reg add 'HKCU\Software\Wine\Direct3D' /v csmt /t REG_DWORD /d 0 /f
  ```
  (value `0` = CSMT disabled). You can verify/toggle it later in `regedit`.
- **Remap ALT -> SUPER (manual, one-time)** — the guide says: *"Change the ALT key
  with SUPER in your Linux OS settings."* Many desktops grab `ALT` for window
  dragging, which steals Lineage 2's `ALT` shortcuts. Do this in your DE, not in
  Wine:
  - **KDE Plasma:** System Settings -> Window Management -> *Window Behavior* ->
    *Moving* -> set the "Window manager modifier" to `Meta` (Super) instead of
    `Alt`.
  - **GNOME:** `gnome-tweaks` -> *Keyboard & Mouse* / *Windows* -> set the window
    action key (mod) to `Super`.
- **Tahoma font fallback** — if text still looks wrong after `winetricks tahoma`,
  drop a `tahoma.ttf` into `~/.wine-l2scarlet/drive_c/windows/Fonts/` as the
  guide suggests.

### Anticheat / Wine compatibility

There is **no kernel-mode anticheat** to block Wine. Scarlet uses only a
user-mode, SmartGuard-class antibot (client/server packet encryption + input
filtering) — no kernel driver, no Vanguard/EAC/BattlEye kernel module. The
strongest proof of Wine-compatibility is that **the server itself publishes an
official WineHQ/Lutris guide** for running the client on Linux.

## Other servers (Orfen / Freya / Gracia Final)

To target a different Scarlet server, open `setup.sh` and replace `CLIENT_URL`
(and mirrors) plus `PATCH_MEGA` with that server's client + system-patch links
from its page, e.g. the Orfen 5x (Etina's Fate) client and patch listed on
<https://orfen.lineage2scarlet.com/>. The rest of the flow (extract -> patch ->
Wine prefix -> tweaks) is identical.

## Troubleshooting

- **Download failed / quota:** the 22 GB client has four mirrors (l2top.co,
  l2db.info, Mega, Google Drive). `setup.sh` prints all of them; download
  manually, save as `~/lineage2-scarlet/fafurion_client.rar`, and re-run.
- **Cannot extract `.rar`:** install `unrar` (or `p7zip-rar`):
  `sudo apt install unrar`.
- **High CPU usage:** confirm CSMT is disabled (see above).
