# L2Warland — "Legacy" (Interlude+)  ⚠️ NOT playable on Linux (WebView2 launcher wall)

**Honest status:** the *client* runs and the anticheat is fine — but Warland is gated behind a
mandatory **64-bit .NET Framework 4.8 + WebView2 launcher** that does **not** run on Wine, Proton 9.0,
**or** GE-Proton11. So despite being the most *stable* server in this repo, it is **not Wine/Proton-
playable** as of mid-2026. Documented here so nobody repeats the multi-hour rabbit hole.

## What works vs. what doesn't
| Layer | Result |
|-------|--------|
| Client extraction | ✅ (password-protected zip, password `warlandlegacy`, AES — use `7z -p`) |
| Anticheat | ✅ **not kernel** — server-side ZeusGuard; bundled `GameGuard.exe`/`npkcrypt.dll` are vestigial |
| `l2.exe` rendering | ✅ renders the Lineage II UI on bare Wine + `winbind` |
| **Login** | ❌ **hangs at "Logging in…" forever** — the client uses **token auto-login** (`GL2UseTokenAutoLogin`); the token only comes from `WarlandLauncher.exe` |
| `WarlandLauncher.exe` | ❌ **the wall** — 64-bit, .NET Framework 4.8, **WebView2** (`Tools/WebView2/WebView2Loader.dll`) |

## Why the launcher can't run (tested exhaustively)
| Environment | .NET runs? | WebView2/Chromium renders? | Result |
|-------------|-----------|----------------------------|--------|
| Bare Wine + wine-mono | ❌ `TypeInitializationException` | — | dead |
| Bare Wine + **real `dotnet48`** + WebView2 runtime | ✅ | ❌ Chromium starts once, **never draws a window** | dead |
| Proton 9.0 (Beta) + WebView2 | ❌ (uses wine-mono) | — | dead |
| **GE-Proton11-1** + WebView2 | ❌ (uses wine-mono) | — | dead |

Two-layered wall: Proton/GE ship **wine-mono**, which can't load this .NET 4.8 assembly; the only env
where the .NET ran (bare Wine + real `dotnet48`) is exactly where **WebView2/Chromium wouldn't render**.

## The takeaway for this repo
A server is Wine/Proton-playable only if login is **in-client** (type credentials at the L2 login
screen — e.g. **ElmoreLab Erica**). Servers fail if they require **(a)** a kernel anticheat *or*
**(b)** a modern **WebView2/.NET token-launcher** like Warland. Proton/GE-Proton fix **neither** of these
for L2 private servers.

## If you still want to try (e.g. on a newer Proton via Steam)
The client install below is reusable; you'd only need the *launcher* to run somewhere it can render
WebView2. Add `WarlandLauncher.exe` to Steam as a non-Steam game on the newest Proton and hope its
Chromium renders — unverified here, and GE-Proton11 (newer than stable Proton) already failed.

```bash
# Downloads from l2warland.com → ~/Downloads:  Warland-Legacy-Client.zip + L2Warland-Patch.zip
./setup.sh        # extracts client (7z -p warlandlegacy), builds prefix — client only
./play.sh         # runs l2.exe → renders, but STOPS at "Logging in…" (no launcher token)
```

- Client zip password: **`warlandlegacy`**. The "system" folder is named **`l2warland/`** (not `system/`).
- `l2.exe` requires **`winbind`** (L2 NTLM auth) to even render.
