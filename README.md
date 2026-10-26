# Iron Clad: static recompilation

**Iron Clad / Choutetsu Brikin'ger (Saurus, 1996) running as a native PC program: its 68000 code is recompiled to C and runs on the [neogeorecomp](https://github.com/sp00nznet/neogeorecomp) board model.**

This repo describes the ROM set and builds the game. The toolkit does all the work; there are no game-specific patches here.

> **No game data here.** You need your own Iron Clad prototype and Neo Geo system ROM dumps (MAME sets `ironclad` and `neogeo`). The recompiled C is generated from your dump on your machine, into `build/`. It is never committed or distributed, and neither is anything else derived from the ROMs.

## Status

**v0.1.0, alpha.** Iron Clad boots through the real MVS system ROM, runs attract mode, takes a coin, starts a game and plays with sound on recompiled code.

- Boot through the real MVS system ROM → eyecatcher → title → attract → gameplay, with a coin and start.
- A ~5-minute scripted soak runs **100% natively** (0 interpreted instructions) after the profile pass, and `--verify` checks **11.06M** recompiled blocks against the Musashi interpreter with **0 mismatches**.
- Frame output is identical to the interpreter's, byte for byte.
- **Sound works**: the Z80 driver runs and the YM2610 (FM, SSG, ADPCM) is synthesized and played through SDL2.

## Prebuilt downloads

The [releases page](https://github.com/omegakatana92/Ironclad-Recomp/releases) has ready-made builds (they still need your own ROMs):

- **Windows x64**: `Ironclad-Recomp-Windows-x64.zip` — unzip, put your ROMs in `roms/`, run `ironclad.exe`.
- **Steam Deck / Linux x64**: `IronClad-x86_64.AppImage` — `chmod +x`, run with `--rom-path` pointing at your ROMs.

## Getting started

### Step by step

**Prerequisites:** Git; CMake 3.21+; a C and C++ compiler (Visual Studio 2022/2026 with *Desktop development with C++* on Windows, or gcc and g++ on Linux); SDL2 for the window (optional, since headless builds need nothing). On Linux: `sudo apt install git cmake gcc g++ libsdl2-dev`.

1. **Clone with the toolkit submodule:**
   ```
   git clone --recurse-submodules <this-repo-url>
   cd ironclad
   ```
2. **Unzip your ROMs into `roms/`.** From `ironclad.zip`: `proto_220-p1.p1 proto_220-s1.s1 proto_220-m1.m1 proto_220-c1.c1 proto_220-c2.c2 proto_220-c3.c3 proto_220-c4.c4 proto_220-v1.v1`. From `neogeo.zip`: `sp-s2.sp1 sfix.sfix sm1.sm1 000-lo.lo`. [docs/game-notes.md](docs/game-notes.md) lists the CRC32s.
3. **Configure.** On Windows, point CMake at SDL2: `-DSDL2_DIR=<SDL2-devel-VC>\cmake` (or vcpkg's toolchain file).
   ```
   cmake -S . -B build -DIRONCLAD_ROM_DIR=roms
   ```
4. **Build.** The generator recompiles your ROMs into `build/generated` first:
   ```
   cmake --build build --config Release
   ```
5. **Profile (optional).** This plays two scripted sessions headless to find code only reached at runtime, then rebuilds with it:
   ```
   cmake --build build --config Release --target profile
   cmake --build build --config Release
   ```
6. **Play:**
   ```
   build/Release/ironclad --rom-path roms          (Linux: build/ironclad)
   ```

Keys: **arrows** move, **Z X C V** = A B C D, **5** insert coin, **1** start, **Esc** quit.

## Usage

```
ironclad --rom-path roms                                     # play
ironclad --headless --frames 19000 --input tests/play_long.txt --record run.mp4
ironclad --headless --verify --frames 19000 --input tests/play_long.txt
ironclad --headless --interp --frames 1801 --screenshot 1800:interp.png
ironclad --headless --frames 19000 --input tests/play_long.txt --wav run.wav   # audio to a file
```

The toolkit's [docs/running.md](https://github.com/sp00nznet/neogeorecomp/blob/master/docs/running.md) covers every option and the input-script format. `tests/coin_start.txt` reaches gameplay, and `tests/play_long.txt` is the soak.

## Documentation

- [docs/game-notes.md](docs/game-notes.md): the ROM set and what the game needed from the toolkit
- [neogeorecomp](https://github.com/sp00nznet/neogeorecomp): the architecture and recompiler docs

## License

This project's own code (the game description, build files, scripts and docs) is licensed under the **PolyForm Noncommercial License 1.0.0** ([LICENSE](LICENSE)). You may use, modify and share it for noncommercial purposes; commercial use is not permitted.

The `neogeorecomp` toolkit is a separate project under the MIT license and remains under its own terms, as do its bundled components (Musashi, z80 and ymfm each keep their own licence). *Iron Clad* is © Saurus/SNK; this project contains none of its code or data and needs your own dump to do anything.
