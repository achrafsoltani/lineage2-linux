# ElmoreLab TEON Example

Automated setup and launch scripts for the ElmoreLab TEON x1 Interlude server on Linux.

## Quick Start

```bash
# 1. Run the setup script (downloads client, creates Wine prefix, runs updater)
./setup.sh

# 2. Register at https://profile.elmorelab.com/

# 3. Launch the game
./play.sh
```

## What setup.sh Does

1. Downloads the prepared Interlude client from Mega via `megadl`
2. Extracts it to `~/L2ElmoreTeon/client/`
3. Creates a 32-bit Wine prefix at `~/.wine-l2teon`
4. Downloads and runs the ElmoreLab updater to fetch latest patches
5. Generates connection-ready client

## Dependencies

- `wine` (9.0+ recommended)
- `python3`
- `7z` (p7zip-full)
- `wget`, `unzip`
- `megatools` (`sudo apt install megatools`)

## Server Details

| Property | Value |
|----------|-------|
| Server | ElmoreLab TEON (x1 Interlude) |
| Rates | EXP/SP x2, Drop x1, Adena x1 |
| Dualbox | Not allowed |
| Anticheat | Server-side anti-exploit + anti-bot CAPTCHA |
| Website | https://elmorelab.com |
| Profile | https://profile.elmorelab.com |
| Forum | https://forum.elmorelab.com |
| Discord | https://discord.gg/CmjKkKRzBA |
