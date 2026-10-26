#!/usr/bin/env bash
# Build the Linux x86_64 player and package a Steam Deck / Linux AppImage.
#
# Prerequisites: gcc, g++, cmake 3.21+, git, make, libsdl2-dev, wget, and the
# neogeorecomp submodule (git submodule update --init --recursive).
#
# Usage:
#   ./scripts/build-appimage.sh [ROM_DIR] [OUTPUT_APPIMAGE]
# Defaults: ROM_DIR=./roms, OUTPUT=./IronClad-x86_64.AppImage
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROMS="${1:-$ROOT/roms}"
OUT="${2:-$ROOT/IronClad-x86_64.AppImage}"
BUILD="$ROOT/build"
APPDIR="$BUILD/AppDir"

echo "== build (Release) =="
cmake -S "$ROOT" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release "-DIRONCLAD_ROM_DIR=$ROMS"
cmake --build "$BUILD" --parallel "$(nproc)"

echo "== assemble AppDir =="
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib" \
         "$APPDIR/usr/share/metainfo" \
         "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/256x256/apps"
cp "$BUILD/ironclad" "$APPDIR/usr/bin/ironclad"
strip --strip-unneeded "$APPDIR/usr/bin/ironclad" 2>/dev/null || true
# Bundle whichever SDL2 the build linked against, so the AppImage is portable.
SDL=$(ldd "$BUILD/ironclad" | awk '/libSDL2-2\.0\.so/{print $3; exit}')
[ -n "$SDL" ] && cp "$SDL" "$APPDIR/usr/lib/"
cp "$ROOT/launcher/ironclad.png" "$APPDIR/ironclad.png"
cp "$ROOT/launcher/ironclad.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/ironclad.png"

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE=$(dirname "$(readlink -f "$0")")
export LD_LIBRARY_PATH="$HERE/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
# If no --rom-path was given, look for a ROM folder beside the AppImage or in
# the usual Deck / desktop locations.
if [ -n "${APPIMAGE:-}" ]; then
    has_rompath=0
    for a in "$@"; do [ "$a" = "--rom-path" ] && has_rompath=1; done
    if [ "$has_rompath" = 0 ]; then
        for d in "$(dirname "$APPIMAGE")/roms" "$HOME/Emulation/roms/ironclad" \
                 "$HOME/roms/ironclad" "$HOME/roms"; do
            if [ -d "$d" ]; then set -- --rom-path "$d" "$@"; break; fi
        done
    fi
fi
exec "$HERE/usr/bin/ironclad" "$@"
EOF
chmod +x "$APPDIR/AppRun"

cat > "$APPDIR/ironclad.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Iron Clad
Comment=Native static recompilation of Choutetsu Brikin'ger / Iron Clad (Neo Geo)
Exec=ironclad
Icon=ironclad
Categories=Game;Emulator;
Terminal=false
EOF
cp "$APPDIR/ironclad.desktop" "$APPDIR/usr/share/applications/ironclad.desktop"

cat > "$APPDIR/usr/share/metainfo/ironclad.appdata.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>io.github.omegakatana92.ironclad</id>
  <name>Iron Clad</name>
  <summary>Native static recompilation of Choutetsu Brikin'ger / Iron Clad</summary>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>LicenseRef-PolyForm-Noncommercial-1.0.0</project_license>
  <description>
    <p>Iron Clad (Choutetsu Brikin'ger, Saurus 1996) with its Motorola 68000
    program statically recompiled to C and run natively on the neogeorecomp
    Neo Geo board model. Requires your own legally obtained ROM dumps.</p>
  </description>
  <launchable type="desktop-id">ironclad.desktop</launchable>
  <url type="homepage">https://github.com/omegakatana92/Ironclad-Recomp</url>
  <provides><binary>ironclad</binary></provides>
  <categories><category>Game</category></categories>
</component>
EOF

echo "== appimagetool =="
TOOL="${APPIMAGETOOL:-$BUILD/appimagetool.AppImage}"
if [ ! -x "$TOOL" ]; then
  wget -q -O "$TOOL" https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
  chmod +x "$TOOL"
fi
ARCH=x86_64 "$TOOL" --appimage-extract-and-run --no-appstream "$APPDIR" "$OUT"
chmod +x "$OUT"
echo "wrote $OUT"
