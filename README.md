# Lineage 2 on Linux

Run the **Lineage 2 client on Linux via Wine** and connect to private servers — with ready-made
setup/launch scripts for several servers in [`examples/`](examples/).

## Tested On

- **OS:** Ubuntu 25.04 (kernel 6.17), **Wine 9.0** — original guide tested on an Intel HD Graphics laptop.
- **Hardware is a non-issue:** the client is a 2007-era DX8/9 game, so even an iGPU runs it; a modern
  GPU (e.g. AMD RX 9060 XT / RDNA4 on Mesa RADV) is massive overkill. Lineage 2 is **Gold-rated** in the WineHQ AppDB.

## The one rule that decides everything: anticheat

A Lineage 2 server is playable on Linux **only if it does _not_ use a kernel-mode anticheat.**
Wine has no Windows kernel, so any client-side anticheat that loads a `.sys` ring-0 driver
**cannot work** — this is a fundamental limitation, not a config issue.

- ✅ **Fine under Wine:** no anticheat, or _server-side_ anti-bot / anti-exploit / CAPTCHA.
- ❌ **Blocks Wine:** **Active Anticheat** (`active64.sys`, active-ac.com), **SmartGuard**, **GameGuard/nProtect**, and similar kernel guards.

Before downloading any client, check the server's site/Discord/files for those names. See
[Spotting kernel anticheat](#spotting-kernel-anticheat-before-you-download) below.

## Servers

Each folder under `examples/` has `setup.sh` (download + Wine prefix + updater + launcher) and
`play.sh`. Run `./setup.sh` then `./play.sh`.

### ✅ Playable on Linux/Wine

| Server | Chronicle / Rates | Notes | Setup |
|---|---|---|---|
| **ElmoreLab — Erica** ⭐ | Interlude **x3** | **best-populated Wine pick (~5k online)**; launched May 2026; 2+1 box, no P2W | [`examples/elmorelab-erica`](examples/elmorelab-erica) |
| **ElmoreLab — Teon** | Interlude **x1** (hardcore) | reputable L2OFF; server-side CAPTCHA; strict no-box | [`examples/elmorelab-teon`](examples/elmorelab-teon) |
| **ElmoreLab — Median** | Interlude **x2** | anticheat-free; allows light boxing; best mainstream Linux pick | [`examples/elmorelab-median`](examples/elmorelab-median) |
| **L2Ghostlands** | Interlude **x4** (24/7) | permanent server; same "Ghost" client as GhostSeason | [`examples/l2ghostlands`](examples/l2ghostlands) |
| **L2GhostSeason** | Interlude **x5** (seasonal) | ⚠️ offline _between_ seasons — use Ghostlands x4 meanwhile | [`examples/l2ghostseason`](examples/l2ghostseason) |
| **Lineage2.MS** | Interlude **x10** (no-wipe) | clean long-term international mid-rate | [`examples/lineage2ms`](examples/lineage2ms) |
| **EURO-PVP** | Interlude **x100 / x1200** | high-rate craft-PvP, mass PvP | [`examples/euro-pvp`](examples/euro-pvp) |
| **Lineage 2 Scarlet** | **Fafurion** (Istina x50, *not* Interlude) | publishes its own WineHQ/Lutris guide — the Linux showcase | [`examples/lineage2-scarlet`](examples/lineage2-scarlet) |

### ❌ Avoid on Linux — kernel anticheat (won't run under Wine)

| Server | Anticheat | Note |
|---|---|---|
| **L2Reborn** | SmartGuard (kernel) | ironically the biggest Interlude server (~7.4k online) — still blocked |
| **Asterios** | own kernel AC | staff statement: *"on Linux our client does not work, and will not work"* |
| **Scryde** / **Battleclub** | client AC | community-confirmed blocked on Proton/Wine |
| **LINEAGE2DEX** | Active Anticheat (`active64.sys`) | dynamic-rate, popular, but kernel driver = no Linux |

> Reality check: the most-populated Interlude servers tend to be the kernel-anticheat ones.
> The Wine-playable servers are smaller/niche — that tradeoff is unavoidable.

## Quick start

```bash
# 1. Install Wine (once)
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install wine wine32 wine64
# some servers also need: sudo apt install megatools p7zip-full p7zip-rar unzip winetricks

# 2. Pick a server and set it up (downloads the client, makes a Wine prefix, writes play.sh)
cd examples/l2ghostlands      # or any folder above
./setup.sh

# 3. Register an account on that server's website, then play
./play.sh
```

Each server uses its **own dedicated 32-bit Wine prefix** (e.g. `~/.wine-l2ghost`,
`~/.wine-l2median`) so they never conflict.

## Tools

### `l2ini.py` — read/modify the encrypted L2.ini

The client's `L2.ini` (which holds the server address) is RSA-encrypted (`Lineage2Ver413` format).
`l2ini.py` decrypts/re-encrypts it so you can point any compatible client at any server:

```bash
python3 l2ini.py status                 # show current server address
python3 l2ini.py decrypt                # decrypt L2.ini to stdout
python3 l2ini.py set 158.220.114.136    # set a custom server address
```

Encryption details: header `Lineage2Ver413` (UTF-16-LE), 1024-bit RSA modulus, decrypt exponent
`0x1d`, 128-byte blocks, zlib-compressed payload prefixed with a 4-byte size.

## Spotting kernel anticheat before you download

1. Read the server's site / FAQ / Discord / rules — look for **"Active Anticheat" / "Active AC"**,
   **"SmartGuard"**, **"GameGuard"**, or a custom **launcher that installs a driver**.
2. **Best test — extract the client and look in `system/` for kernel `.sys` drivers** (cleaner than
   running it). Any of these = kernel anticheat = **won't run on Wine**:
   - `npkcrypt.sys` / `npkcusb.sys` / `GameMon.des` / `system/GameGuard/` → **GameGuard** (nProtect)
   - `active64.sys` / an Active updater → **Active Anticheat**
   - a `SmartGuard` folder / `SmartGuard.ini` → **SmartGuard**
   (Real example: ForcePlay's client ships `system/npkcrypt.sys`, `system/npkcusb.sys`, and
   `system/SmartGuard` — confirmed Wine-blocked despite advertising only a vague "ForcePlay Guard".)
3. ⚠️ **A clean `system/` scan is NOT proof of safety.** **Active Anticheat fetches/loads its kernel
   driver at *runtime***, so also **run the client and watch for an "Active Launcher" window/process:**
   `xwininfo -root -tree | grep -i 'active launcher'`. Real example: **BOHPTS**'s `system/` looked clean
   (only vestigial GameGuard DLLs), yet launching `l2.exe` spawned an **Active Launcher** → Wine-blocked.
4. Server-side CAPTCHA / anti-exploit and a plain file-validation updater are **fine**.

## Troubleshooting

- **"Can't bind to native class Engine.SkillVisualEffect"** — mismatched DLLs. `engine.dll`,
  `Core.dll`, etc. must come from the *same* client build as `L2.exe`. Use the provided client as-is.
- **Wrong server name in the list** — names come from local `servername-e.dat` in `system/`, not the
  auth server. Use the file that shipped with that server's client.
- **"Active Anticheat — Driver installation error(11)"** — the server needs a kernel anticheat; it
  will not work on Linux. Choose an anticheat-free server (see the table above).
- **Login page appears but credentials fail** — `L2.ini` points at the wrong server; fix with
  `python3 l2ini.py set <ip>`.
- **Wine prefix errors / `chdir`** — delete and recreate the prefix:
  `rm -rf ~/.wine-<server> && WINEPREFIX=~/.wine-<server> WINEARCH=win32 wineboot --init`.

## Notes

- The game is a 32-bit Windows app — a `WINEARCH=win32` prefix works best.
- `WINEDEBUG="-all"` (used in the scripts) silences noisy Wine output; drop it to debug.
- A pre-installed Interlude client is ~6.4 GB extracted; budget ~9 GB free for download + extract.
- Most clients need **no** winetricks/native DLLs. Scarlet is the exception (see its README:
  corefonts, d3dx9, disable CSMT, ALT→SUPER remap).
