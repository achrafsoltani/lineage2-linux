# Lineage2.MS Example

Automated setup and launch scripts for the **Lineage2.MS** Interlude x10 (no-wipe)
private server on Linux under Wine.

## Quick Start

```bash
# 0. Install the extra dependency (MEGA downloader)
sudo apt install megatools

# 1. Run the setup script (downloads ~5 GB client + MS Patch, extracts, patches)
./setup.sh

# 2. Register at https://lineage2.ms/sign-up

# 3. Launch the game (pick your proxy region at the login screen)
./play.sh
```

## What setup.sh Does

1. Downloads the **Interlude client** (~5 GB) and the **MS Patch** from the official
   MEGA mirrors via `megadl`. If MEGA fails (it rate-limits ~5 GB/day on free
   transfers) it prints exact manual-download instructions and stops cleanly.
2. Extracts the client into `./client/`.
3. **Deletes the client's `/system` folder, then applies the MS Patch** — this is
   the install order the server itself requires; without the patch you cannot
   connect.
4. Normalises the layout so `client/system/L2.exe` exists.
5. Creates a 32-bit Wine prefix at `~/.wine-l2ms`.
6. Generates a `play.sh` launch script.

> The MS Patch is mandatory. The full client without the patch will not connect.
> If you already have an Interlude client you only need the patch, but this script
> installs both for a clean, known-good result.

## Dependencies

- `wine` (9.0+ recommended)
- `python3`
- `7z` (`p7zip-full`)
- `wget`
- `megatools` (`sudo apt install megatools`) — provides `megadl` for the MEGA mirrors

## Server Details

| Property | Value |
|----------|-------|
| Server | Lineage2.MS (Interlude / Chronicle 6) |
| Rates | x10 (Luna): EXP/SP x10, Adena x1, Drop x1 — x2-x3 / x15 via vote/Luna Plus. (Sister "Moon" server is x30.) |
| Wipe policy | No-wipe — seasonal servers merge into the permanent OLD server |
| Dualbox | 1+1 allowed (with restrictions) |
| Anticheat | Userspace client protection in the MS Patch (packet encryption / anti-bot). **No kernel-mode driver** |
| Server address | Baked into the patched `L2.ini`; proxy region (UA/EU, KZ/ASIA, USA/BRASIL) chosen at the login screen — no public IP/port is published |
| Website | https://lineage2.ms |
| Download page | https://lineage2.ms/en/start |
| Register | https://lineage2.ms/sign-up |
| Discord | https://discord.gg/lineage2ms |
| Forum | https://forum.lineage2.ms |

## Optional: Launcher MS

The server also offers a Windows "Launcher MS" (`Launcher_MS.zip`) that auto-applies
patches and presses Play. It is a .NET app and is **not required** — `play.sh` runs
`L2.exe` directly, which is simpler and more reliable under Wine. If you want it,
download it from https://lineage2.ms/en/start, drop it in the client folder, install
.NET in the prefix with `WINEPREFIX=~/.wine-l2ms winetricks dotnet48`, and run it.

## Wine Notes

- **No kernel anticheat.** Lineage2.MS protection lives entirely in userspace (the
  MS Patch does client/server packet protection), so Wine can load it. This is unlike
  servers using Active Anticheat (`active64.sys`), which require a Windows kernel
  driver that Wine cannot load.
- Use the dedicated **32-bit** prefix (`~/.wine-l2ms`, `WINEARCH=win32`) that
  `setup.sh` creates. A 64-bit prefix is more likely to misbehave with the old
  Interlude engine.
- If you get a protection / packet error at login, delete and recreate the prefix
  (`rm -rf ~/.wine-l2ms` then re-run `setup.sh`), and install the common L2 runtime
  bits: `WINEPREFIX=~/.wine-l2ms winetricks corefonts d3dx9 vcrun2008`.
- **KDE Alt-key clash:** Lineage 2 uses **Alt** for next-target / Alt+click, but KDE
  (and GNOME) grab Alt+drag to move windows. Remap the window modifier to Meta/Super:
  KDE System Settings -> Window Management -> Window Behavior -> Window Actions ->
  set the "Move window" modifier key from `Alt` to `Meta`.
- `WINEDEBUG="-all"` (set in `play.sh`) silences Wine's debug spam. Remove it if you
  need to troubleshoot a crash.
- If textures/UI look broken, try enabling CSMT (default on in Wine 9) and the
  `d3dx9` winetricks verb above; the Interlude client renders via Direct3D 9.

## Troubleshooting

- **"Cannot connect" / stuck at login** — you skipped the MS Patch, or `L2.ini` is
  from a different client. Re-run `setup.sh` so the patch overwrites `/system`.
- **MEGA download fails** — MEGA caps free transfers; use the MediaFire or Google
  Drive mirror listed by `setup.sh`, save the file to the install dir with the exact
  name it asks for, and re-run `setup.sh`.
- **Crash on start** — make sure you did not mix DLLs from another Interlude client.
  Let the MS Patch own the entire `system/` folder.
