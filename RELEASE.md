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

## Downloads

| Platform | File | Notes |
|---|---|---|
| Windows 10/11 x64 | `Ironclad-Recomp-Windows-x64.zip` | Unzip anywhere, put your ROMs in a `roms/` folder beside `ironclad.exe`, then run it. Bundles SDL2 and the VC++ runtime DLLs. |
| Steam Deck / Linux x64 | `IronClad-x86_64.AppImage` | `chmod +x IronClad-x86_64.AppImage`, then run it. It auto-finds ROMs beside the AppImage (`roms/`) or in `~/Emulation/roms/ironclad`, `~/roms/ironclad`, `~/roms`; otherwise pass `--rom-path <folder>`. SDL2 is bundled, and the binary is stripped. Built on Ubuntu 22.04 (glibc 2.35) for SteamOS compatibility. |

Both builds contain the same 100% recompiled code and **no game data**: you must supply your own `ironclad` and `neogeo` ROM sets (put them in `roms/`, or point `--rom-path` at them).

### Steam Deck

1. Copy `IronClad-x86_64.AppImage` and your ROM folder to the Deck (e.g. `~/Emulation/roms/ironclad`).
2. `chmod +x IronClad-x86_64.AppImage`.
3. In Desktop Mode, add it as a non-Steam game (Games → Add a Non-Steam Game), or launch from Konsole:
   `./IronClad-x86_64.AppImage --rom-path ~/Emulation/roms/ironclad`
4. The Deck's built-in pad is an SDL2 gamepad: D-pad/stick move, **A/B/X/Y** = A/B/C/D, **Start** = start, **Back** = coin.

## Requirements

- Windows 10/11 x64 (the shipped player bundles SDL2 and the VC++ runtime DLLs), or Linux x64 / SteamOS (the AppImage bundles SDL2).
- Your own legally obtained ROM dumps: MAME sets `ironclad` (the ID-0220 prototype) and `neogeo`.

No ROMs or BIOS images are distributed. The recompiled program is generated from your dump on your machine at build time; the prebuilt binaries embed that same recompiled program and still require your ROMs to run.

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
