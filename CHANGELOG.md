# Changelog

All notable changes to this project. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow SemVer.

## [0.1.0] - 2026-10-25

### Added
- First port of *Iron Clad / Choutetsu Brikin'ger* (ID-0220 prototype) to the neogeorecomp board model, with no toolkit changes.
- ROM set description (`ng_game_t`) for the MAME `ironclad` prototype, including its single ADPCM V ROM.
- Attract-mode and play-soak input scripts (`tests/coin_start.txt`, `tests/play_long.txt`).
- Setup scripts (Windows PowerShell, Linux/macOS bash) and a `launcher.json` for the recomp-launcher.

### Verified
- Boots through the real MVS BIOS to the title and attract mode.
- 100% native (0 interpreted instructions) over the attract + ~5-minute play soak after the profile pass.
- `--verify`: 11,062,666 blocks, 0 mismatches.
- Native frames byte-identical to the interpreter.
- Audio non-silent across the soak (YM2610 FM/SSG/ADPCM).
