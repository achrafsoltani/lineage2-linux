# Active Lineage 2 servers that run on Linux/Wine — census (late June 2026)

Researched + verified for **two** things: (1) genuinely **active/populated** in mid-2026 (recent
patches, live Discord, real concurrent counts — *not* just a live homepage), and (2) **no kernel-mode
anticheat** (the only hard blocker for Wine — see [the rule](README.md#the-one-rule-that-decides-everything-anticheat)).

> ⚠️ **Mid-rate (x20–x50) is a dead zone on Linux right now.** Every live server in that band uses
> kernel anticheat or is abandoned. Real options are **low-rate** or **high-rate PvP** — or wait for
> **L2Warland x20** (opens **16 Oct 2026**).

## ✅ Active & Linux-playable

> ⚠️ **Confidence note:** anticheat below was judged from research + each server's site/claims —
> **not** by running every launcher. A server billed as "L2J / no anticheat" can still ship a
> client-side **"Active Launcher" (Active Anticheat, kernel)** — that's exactly how **Exilium (Faris)**
> slipped past the first pass. **Only ElmoreLab (Erica) is *run-verified* on this machine** (reached
> login). Treat the rest as "should work — confirm on first launch; **an _Active Launcher_ dialog
> means kernel anticheat → it won't run on Wine.**"

### Low-rate (x1–x7) — the strongest band on Linux
| Server | Chronicle / Rate | Population (2026) | Wine | Notes |
|---|---|---|---|---|
| **ElmoreLab — Erica** | Interlude **x3** | ~3,000 concurrent | ✅ confirmed | you're already on it; fresh (May 2026) |
| **Melior** | **Classic** Kamael x3 | ~570–870 (#1 Classic) | ✅ no kernel AC | top Classic server; Melior.exe = patcher only |
| **ElmoreLab — Median** | Interlude **x2** | fresh (Jun 7), healthy | ✅ confirmed | Remastered ruleset |
| **ElmoreLab — Kamael x3** | Classic-era **x3** | populated | ✅ likely | L2OFF |
| **L2frenzy — Oryn** | Interlude **x3** | ~200 | ✅ no kernel AC | L2J; launcher bypassable via l2.exe |
| **ElmoreLab — Teon** | Interlude **x1** | past peak | ✅ confirmed | hardcore, strict no-box |

### Essence (retail-core, x1)
| Server | Rate | Population | Wine | Notes |
|---|---|---|---|---|
| **L2EVA** | Essence **x1** (P2W stripped) | ~315 | ✅ no kernel AC | custom *userland* "EVA Guard" (no .sys) — but **Wine-untested + HWID bans**, so test cautiously |

### High-rate / PvP (x75+)
| Server | Chronicle / Rate | Population | Wine | Notes |
|---|---|---|---|---|
| **EURO-PVP** | Interlude **x100 / x1200** | moderate (re-verify) | ✅ no kernel AC | repo scaffold exists |

### More Wine-safe finds — l2servers.com + l2.hopzone.net sweep (Jun 2026)
*All 🟡 research-verified with a rigorous anticheat hunt (no kernel-AC tells) — still confirm on first launch.*

| Server | Chronicle · Rate | Band | Pop | Note |
|---|---|---|---|---|
| **L2Cygnus** | Interlude · x999 GvE faction PvP | pvp | ~817 votes, fresh season Jun 27 | since 2015; CygnusLauncher = benign file-updater (deeply verified) |
| **L2Return** | Interlude · x2000 PvP | pvp | ~194, fresh wipe Jun 12 | runs `l2.exe` directly, **no launcher** |
| **Lineage 2 Death** | Interlude · x10000 Mega-PvP | pvp | active (season May 2026) | vanilla client + patch |
| **L2 Crossover** | High Five · x2 | low | 48 online (confirmed live via API) | custom updater, no AC found |
| **L2Cat** (ex-L2KOT) | Interlude · x1–x10 no-wipe | low | ~20–30 (since 2017) | **bots allowed** → definitely no client AC; runs `l2.exe` |
| **L2Equinox** | Interlude · x2500 PvP | pvp | tiny (~17), very new | backup |
| **Destarion** | High Five · x300 | pvp | moderate; x300 opened Jun 5 | ⚠️ mandatory launcher, no AC tells but **unverified** |

### Mid-rate (x10–x50) — ⚠️ still almost nothing on Linux
| Server | Rate | Status |
|---|---|---|
| **L2Set (SET Classic)** | Interlude **x10** | 🟡 live but TINY (~15 online); no AC found — the only live mid-rate Wine-safe find |
| **L2Warland (Legacy)** | x12 / x3 now; **x20 opens 16 Oct 2026** | Linux-safe (ZeusGuard, not kernel) — but the x20 world isn't live yet |

### 🐧 Most Linux-friendly, but near-empty
| Server | Chronicle / Rate | Population | Wine | Notes |
|---|---|---|---|---|
| **Lineage 2 Scarlet** | Fafurion **x50** / Gracia **x20** / Freya **x15** / Orfen **x5** (not Interlude) | ~13–26/server (~400 community) | ✅✅ official WineHQ/Lutris guide | *The* most Linux-friendly server (dev publishes a Wine guide) — but population is very thin, so it reads "up but quiet." Repo scaffold ready (`examples/lineage2-scarlet/`), not installed. Needs `winetricks corefonts d3dx9 vcrun2008` + disable CSMT. |

### Hopzone premium sweep (Jun 2026) — verified, anticheat-hunted
Key realization: **populated ⇏ always kernel-AC.** Servers with built-in **autofarm** are Wine-safe
*because* they embrace botting (you can't ship an anti-bot kernel driver alongside `.autofarm`).

| Server | Chronicle · Rate | Pop | Wine | Note |
|---|---|---|---|---|
| **BOHPTS** ⭐ | Interlude **x7** | **~5,000 online** | 🟡 no AC (L2J) | **the standout — populated *and* low-rate *and* Wine-safe** |
| **L2-SAVAGE** | High Five **x5** | active (~99k votes) | 🟡 no AC | fresh-start low-rate |
| **MOON-LAND** | Interlude **x15000** | active (#1 votes) | 🟡 no AC | built-in autofarm; churny custom-PvP |
| **L2DAMAGE** | Interlude **x9000** | ~518 online | 🟡 no AC | autofarm, runs `l2.exe` directly |
| **L2AURUM** · **LA2BEST** · **L2WorldWar** · **L2DARKNESS** | Interlude x100–x300 | active | 🟡 no AC | autofarm / faction-PvP |
| **L2PWNER** | Interlude **x1000** | modest | 🟡 no AC | seasonal wipes |
| **Project-Ortos** | Gracia Epilogue **x15** | young, real (~2k votes/mo) | 🟡 no AC | best Wine-safe **mid-rate** |
| L2Avalon x50 · L2Meta x50 · L2Goldhart x45 · L2Lethal x45 | Interlude mid | small / pre-launch | 🟡 no AC | Wine-safe but near-empty or not-yet-open |
| **KetraWars** · **LOE** · **Aden.Land** | Essence x1 | modest | 🟡 no AC | Essence options |

⚪ Wine-safe but **dead/near-empty:** L2DarkElegy (HF x35, ~8 online) · JoinEldoria (HF x8 beta).

## ❌ Avoid

### Dead (homepage up, no players)
**L2Etina** (also kernel AC) · **L2Age** (own tracker 0 online) · **Inera** · **Lin2Century** ·
**Elmoreden World** · **ElmoreLab Airin** (merged away).

### Kernel anticheat → cannot run on Wine (includes the most popular servers)
**L2Reborn** (SmartGuard) · **Asterios** (own kernel AC; staff: *"will not work on Linux"*) ·
**Scryde** · **Battleclub** · **L2MAD** · **L2-Titan** (x25) · **Flauron** (x50, `active64.sys`) ·
**ForcePlay** (x25) · **LINEAGE2DEX** (x25) · **L2Eirin** (x30) · **official NCSoft / Essence** (GameGuard) ·
**Exilium World** (one server, "Faris" — ships the *Active Launcher* / Active Anticheat; census wrongly rated it L2J-no-AC) ·
**L2Amerika** (HF x200, ~365 online #7 — **Active Anticheat**, same vendor as Exilium) · **100ka** (Interlude x40 — **SmartGuard**; site also down) ·
**DESTORUS** (Interlude x10000 — **Active Anticheat**, despite "autofarm" marketing) · **L2Turan** (Interlude x7 — **Active Anticheat**) · **MithrilMines** (Classic x100 — **SmartGuard**).

> The three biggest L2 servers in mid-2026 (Reborn, Asterios, and the big auto-farm Interlude
> projects) are all kernel-anticheat — unplayable on Linux. The trade-off (popular = kernel AC) is real.

## Picking a second server (since mid-rate is out)
- **Safest — proven on this rig** → another **ElmoreLab** (**Median x2** or **Kamael x3**): same install flow that worked for Erica; server-side CAPTCHA, no client anticheat.
- **Populated, different chronicle — but research-only, verify on launch** → **Melior (Classic x3)**, #1 Classic server.
- **Set on true mid-rate (x20)?** → **wait for L2Warland x20 (16 Oct 2026)**; nothing good is live in that band now.

*Method: cross-checked nostalgic.gg live Discord-integration tracker (~81 active servers / ~16k
concurrent, late Jun 2026) against each server's own site, patch dates, and anticheat docs. Population
fluctuates — confirm the Discord before investing.*
