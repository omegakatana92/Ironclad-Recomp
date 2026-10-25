# Iron Clad: notes

What this title needs from the toolkit, and what bringing it up showed. These notes cover behaviour only. Code addresses, disassembly and anything else lifted from the ROM are not published (REPO_RULES section 3).

## The set

MAME set `ironclad` (the ID-0220 *Choutetsu Brikin'ger / Iron Clad* prototype), plus the `neogeo` system set.

| File | Size | CRC32 | Role |
|---|---|---|---|
| `proto_220-p1.p1` | 2 MB | `62a942c6` | 68000 program. The second MB is the fixed `$000000` bank and the first MB is the banked half; stored byte-swapped |
| `proto_220-s1.s1` | 128 KB | `372fe217` | fix layer tiles |
| `proto_220-c1.c1`..`proto_220-c4.c4` | 4 × 4 MB | `9aa2b7dc` `8a2ad708` `d67fb15a` `e73ea38b` | sprite tiles, two odd/even pairs |
| `proto_220-m1.m1` | 128 KB | `3a08bb63` | Z80 sound driver |
| `proto_220-v1.v1` | 4 MB | `8f30a215` | ADPCM samples (this prototype has a single V ROM) |
| `sp-s2.sp1` | 128 KB | `9036d879` | MVS system ROM (Asia/Europe v2) |
| `sfix.sfix`, `sm1.sm1`, `000-lo.lo` | | `c2ea0cfd` `94416d67` `5a86cff2` | BIOS fix tiles, BIOS sound driver, sprite shrink table |

The board has no protection, no encryption, and no extra cartridge hardware. The layout is the plain 2 MB P ROM pattern the toolkit already models, so the `ng_game_t` is a direct copy of the MAME definition with no surprises.

Note: some dumps of this game circulate with a bootleg program ROM (`ironclado`, CRC `ce37e3a0`, sometimes named `220-p1a.bin`). It is not part of this set; only `proto_220-p1.p1` is used.

## What it exercises

- **Boot through the real MVS BIOS**: RAM test, Z80 handshake (the BIOS switches from its own sound driver to the cartridge's), eyecatcher, coin and credit handling, and the attract loop.
- **Sprites**: the player ship and enemies are multi-sprite objects, so sticky chains and the shrink tables matter.
- **VBlank** drives the game loop through the BIOS, and the title/demo uses palette banks.
- **Audio**: the Z80 driver runs the YM2610 with FM, SSG and ADPCM from the single V ROM.

## What discovery had to learn

Iron Clad, like Metal Slug, dispatches most of its logic through pointers rather than direct calls:

- **Objects run as coroutines.** A routine stores its resume address in the object's RAM and the object loop later jumps there, so a lot of code is only referenced from data. Static discovery found most of it via the pointer scan, but the game's per-frame object and sprite loops expose resume points only at runtime.
- **A profile pass completes coverage.** One attract session plus one ~5-minute play session (`tests/play_long.txt`) added the remaining runtime-only entry points.

End state, after the profile pass: 359,204 instructions emitted across 6,801 routines and 8,831 dispatch entries. The attract + play soak runs with 0 interpreted instructions, and `--verify` finds 0 mismatches over 11.06M blocks. Audio is non-silent across the soak.

## Not yet

- Only the attract mode and the scripted play session have been driven automatically; stages beyond what `play_long.txt` reaches have not been exercised by a script yet. Any runtime-only code they hit will run in the interpreter until profiled (correctly, via the Musashi fallback).
- Interactive gamepad play on a real device has not been performed (the SDL2 window launches and accepts keyboard input; gamepad mapping is the toolkit's default).
