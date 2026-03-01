# Lineage 2 Interlude on Linux

Guide to running Lineage 2 Interlude (GhostSeason private server) on Linux using Wine.

## Tested On

- **OS:** Ubuntu 25.04 (kernel 6.17)
- **Wine:** 9.0 (Ubuntu package `wine`)
- **CPU:** Intel Core i7 Ultra 7 165U
- **GPU:** Intel HD Graphics 4000 (integrated)

## Server

- **Name:** L2GhostSeason (x5 Interlude)
- **Website:** https://l2ghostseason.com
- **Auth server:** 158.220.114.136:2106
- **Game server:** 158.220.114.136:7777
- **Protocol:** Standard L2 Interlude (no proxy protocol, no anticheat)

## Why GhostSeason

Many Interlude private servers ship with **Active Anticheat** (active-ac.com), which loads a Windows kernel driver (`active64.sys`). Wine cannot load kernel drivers — this is a fundamental limitation, not a configuration issue. GhostSeason uses a clean, unmodified Interlude client with no anticheat, making it fully compatible with Wine.

## Installation

### 1. Install Wine

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install wine wine32 wine64
```

Verify:

```bash
wine --version
# wine-9.0 or later
```

### 2. Download the Pre-Installed Client

Go to https://l2ghostseason.com and download the **pre-installed client** (not the patch). Available on MEGA and MediaFire (~2.4 GB).

Extract it:

```bash
mkdir -p ~/Downloads/L2GhostSeason
cd ~/Downloads/L2GhostSeason
7z x "Lineage_II_Interlude_Ghostlands_Client_[pre-installed].7z"
mv "Lineage II Interlude Ghostlands Client [pre-installed]/Lineage II" client
rm -rf "Lineage II Interlude Ghostlands Client [pre-installed]"
```

The game folder should look like:

```
L2GhostSeason/
└── client/
    ├── animations/
    ├── maps/
    ├── music/
    ├── sounds/
    ├── staticmeshes/
    ├── system/          # L2.exe, Core.dll, engine.dll, l2.ini, ...
    ├── systextures/
    ├── textures/
    └── voice/
```

### 3. Create a Wine Prefix

Use a dedicated 32-bit prefix to avoid conflicts with other Wine applications:

```bash
WINEPREFIX=~/.wine-l2ghost WINEARCH=win32 wineboot --init
```

### 4. Run the Updater (Optional but Recommended)

The pre-installed client ships with `L2GhostUpdater.exe`. Run it once to pull the latest patches:

```bash
cd ~/Downloads/L2GhostSeason/client
WINEPREFIX=~/.wine-l2ghost WINEDEBUG="-all" wine L2GhostUpdater.exe
```

A GUI window will appear. Let it finish updating, then close it.

### 5. Register an Account

Create an account at https://l2ghostseason.com/accounts.php before launching the game.

### 6. Launch the Game

```bash
cd ~/Downloads/L2GhostSeason/client/system
WINEPREFIX=~/.wine-l2ghost WINEDEBUG="-all" wine L2.exe
```

Or use the launch script (see below).

## Launch Script

Create `play.sh` in the game root:

```bash
#!/bin/bash
cd "$(cd "$(dirname "$0")" && pwd)/client/system"
WINEPREFIX="$HOME/.wine-l2ghost" WINEDEBUG="-all" wine L2.exe
```

```bash
chmod +x play.sh
./play.sh
```

## L2.ini Encryption

The L2.ini config file is RSA-encrypted (Lineage2Ver413 format). To read or modify it (e.g. change the server address), you need to decrypt it first. See `l2dex.py` in the tools section below for a Python script that handles this.

The encryption uses these parameters:
- **Header:** `Lineage2Ver413` (UTF-16-LE)
- **RSA modulus:** 1024-bit
- **Decryption exponent:** 0x1d (29)
- **Block size:** 128 bytes
- **Payload:** zlib-compressed plaintext, prefixed with a 4-byte uncompressed size

## Tools

### l2ini.py — L2.ini Decrypt/Encrypt Tool

A standalone Python script for reading and modifying the encrypted L2.ini:

```bash
# Show current server address
python3 l2ini.py status

# Decrypt L2.ini to stdout
python3 l2ini.py decrypt

# Set a custom server address
python3 l2ini.py set 158.220.114.136
```

See [l2ini.py](l2ini.py) for the full source.

## Troubleshooting

### Game crashes with "Can't bind to native class Engine.SkillVisualEffect"

You are using mismatched DLLs. The `engine.dll`, `Core.dll`, and other DLLs must come from the same client build as `L2.exe`. Do NOT mix DLLs from different Interlude clients. Use the pre-installed client download as-is.

### Game shows wrong server name in server list

Server names come from the local `servername-e.dat` file in the `system/` directory, not from the auth server. Make sure you're using the server name file that came with the GhostSeason client.

### "Active Anticheat - Driver installation error(11)"

This means the server requires Active Anticheat, which needs a Windows kernel driver. Wine cannot load kernel drivers. This server will not work on Linux. Choose a server without anticheat (like GhostSeason).

### Login page appears but credentials don't work

Verify the L2.ini points to the correct server. If you previously used a different server's files, the L2.ini may still contain the old server address.

### Wine prefix errors

If you see `chdir` errors or strange behaviour, delete the prefix and recreate it:

```bash
rm -rf ~/.wine-l2ghost
WINEPREFIX=~/.wine-l2ghost WINEARCH=win32 wineboot --init
```

## Notes

- The game runs as a 32-bit Windows application under Wine. A 32-bit prefix (`WINEARCH=win32`) works best.
- `WINEDEBUG="-all"` suppresses noisy Wine debug output. Remove it if you need to troubleshoot.
- The pre-installed client is ~6.4 GB extracted.
- No special Wine overrides (winetricks, native DLLs) are needed.
