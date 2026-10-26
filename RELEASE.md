# Iron Clad — Native Static Recompilation (v0.1.0)

**Choutetsu Brikin'ger / Iron Clad (Saurus, 1996) recompiled from Motorola 68000 to native C and run on the [neogeorecomp](https://github.com/sp00nznet/neogeorecomp) board model.**

This is not an emulator or a ROM launcher. The game's 68000 program is translated ahead of time into C, compiled into the player, and executed natively against a software model of the Neo Geo MVS hardware. The only interpreter left is the toolkit's Musashi fallback for addresses that have no recompiled entry.

## Highlights

- **Real native execution.** 361,444 instructions across 6,805 routines and 8,835 dispatch entry points, generated from the MAME `ironclad` prototype set.
- **Correctness.** `--verify` replays every native block in Musashi and compares registers, flags and bus writes. Results:
  - boot + gameplay: **855,321 blocks, 0 mismatches**
  - full ~5-minute soak: **11,062,666 blocks, 0 mismatches**
  - death/continue/menu coverage: **7,066,717 blocks, 0 mismatches**
- **100% native coverage** over the attract mode, the scripted play soak, and a death/continue/test-menu pass: **0 interpreted instructions, 0 uncovered entry points**.
- **Byte-identical frames** between the native build and the interpreter.
- **Working audio.** The Z80 runs the real sound driver; the YM2610 (FM, SSG, ADPCM) is synthesized and non-silent across the soak.
- **Controls.** Keyboard and SDL2 gamepads, the toolkit defaults.

## Requirements

- Windows 10/11 x64 (the shipped player bundles SDL2 and the VC++ runtime DLLs), or Linux x64 built from source.
- Your own legally obtained ROM dumps: MAME sets `ironclad` (the ID-0220 prototype) and `neogeo`.

No ROMs, BIOS images, or ROM-derived generated code are distributed in this repository. The recompiler produces the C from your dump on your machine at build time.

## Build and play

```
git clone --recurse-submodules <this repo>
cd Ironclad-Recomp
# put the game + BIOS files in roms/ (see docs/game-notes.md for names and CRCs)
cmake -S . -B build -DIRONCLAD_ROM_DIR=roms
cmake --build build --config Release
build/Release/ironclad --rom-path roms
```

Keys: arrows move, **Z X C V** = A B C D, **5** insert coin, **1** start, **Esc** quit.

## Status and limitations

Alpha. The title boots through the real MVS BIOS, runs attract mode, and plays on 100% recompiled code for the scripted paths. Stages beyond the scripted soak, interactive gamepad hardware, and game-over/continue were only partially exercised; anything not yet profiled still runs correctly through the Musashi fallback. No memory card, AES BIOS or PAL timing (toolkit roadmap).

## License

The project's own code is licensed under the **PolyForm Noncommercial License 1.0.0** — free to use, modify and share for noncommercial purposes; commercial use is not permitted. The `neogeorecomp` toolkit and its components (Musashi, z80, ymfm) keep their own MIT/BSD licenses. *Iron Clad* is © Saurus/SNK; you must supply your own ROM dump.
