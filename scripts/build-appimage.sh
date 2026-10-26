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
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib"
cp "$BUILD/ironclad" "$APPDIR/usr/bin/ironclad"
# Bundle whichever SDL2 the build linked against, so the AppImage is portable.
SDL=$(ldd "$BUILD/ironclad" | awk '/libSDL2-2\.0\.so/{print $3; exit}')
[ -n "$SDL" ] && cp "$SDL" "$APPDIR/usr/lib/"
cp "$ROOT/launcher/ironclad.png" "$APPDIR/ironclad.png"
cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE=$(dirname "$(readlink -f "$0")")
export LD_LIBRARY_PATH="$HERE/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
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
Categories=Game;
Terminal=false
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
