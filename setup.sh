#!/usr/bin/env bash
# Quick start for Iron Clad on Linux/macOS: checks prerequisites, finds your
# ROMs, builds, and makes a launcher. Details go to setup.log.
set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG="$ROOT/setup.log"
ROMS="$ROOT/roms"
BUILD="$ROOT/build"
: > "$LOG"
log(){ echo "$*" | tee -a "$LOG"; }

ROM_ZIP=""; BIOS_ZIP=""; YES=0; NO_WINDOW=0
while [ $# -gt 0 ]; do
  case "$1" in
    --rom-zip) ROM_ZIP="$2"; shift 2 ;;
    --bios-zip) BIOS_ZIP="$2"; shift 2 ;;
    --yes) YES=1; shift ;;
    --no-window) NO_WINDOW=1; shift ;;
    *) shift ;;
  esac
done

need(){ command -v "$1" >/dev/null 2>&1; }
ask(){ if [ "$YES" = 1 ]; then log "$1 -> yes"; return 0; fi; read -r -p "$1 [y/N] " a; log "$1 -> $a"; case "$a" in y|Y|yes|YES) return 0;; *) return 1;; esac; }

for c in git cmake cc g++ make; do
  if ! need "$c"; then log "missing: $c (install it and rerun)"; exit 1; fi
done

# toolkit submodule
if [ ! -f "$ROOT/neogeorecomp/ext/musashi/m68k_in.c" ]; then
  if [ -d "$ROOT/.git" ]; then
    git -C "$ROOT" submodule update --init --recursive || { log "submodule fetch failed"; exit 1; }
  else
    REF="$(head -n1 "$ROOT/toolkit.ref" | tr -d '[:space:]')"
    rm -rf "$ROOT/neogeorecomp"
    git clone https://github.com/sp00nznet/neogeorecomp.git "$ROOT/neogeorecomp" || exit 1
    git -C "$ROOT/neogeorecomp" checkout "$REF" || exit 1
    git -C "$ROOT/neogeorecomp" submodule update --init --recursive || exit 1
  fi
fi
log "toolkit ready"

# ROMs (copy from a folder if present, else unpack the zips)
mkdir -p "$ROMS"
find_zip(){ # name, given
  if [ -n "$2" ] && [ -f "$2" ]; then echo "$2"; return; fi
  for p in "$ROOT" "$ROMS" "$HOME/Downloads" "$HOME/Desktop"; do
    if [ -f "$p/$1" ]; then echo "$p/$1"; return; fi
  done
  echo ""
}
unpack(){ # zip, list of names
  local z="$1"; shift
  python3 - "$z" "$@" <<'PYEOF'
import sys, zipfile
z, names = sys.argv[1], sys.argv[2:]
with zipfile.ZipFile(z) as f:
    for n in names:
        m = next((i for i in f.namelist() if i.lower().endswith('/'+n.lower()) or i.lower()==n.lower()), None)
        if m:
            with f.open(m) as src, open('roms/'+n,'wb') as dst:
                dst.write(src.read())
PYEOF
}
GAME_FILES="proto_220-p1.p1 proto_220-s1.s1 proto_220-m1.m1 proto_220-c1.c1 proto_220-c2.c2 proto_220-c3.c3 proto_220-c4.c4 proto_220-v1.v1"
BIOS_FILES="sp-s2.sp1 sfix.sfix sm1.sm1 000-lo.lo"
if ! ls "$ROMS"/proto_220-* >/dev/null 2>&1; then
  z="$(find_zip ironclad.zip "$ROM_ZIP")"
  [ -n "$z" ] && unpack "$z" $GAME_FILES || { log "place ironclad.zip in $ROOT or pass --rom-zip"; exit 1; }
fi
if ! ls "$ROMS"/sp-s2.sp1 >/dev/null 2>&1; then
  z="$(find_zip neogeo.zip "$BIOS_ZIP")"
  [ -n "$z" ] && unpack "$z" $BIOS_FILES || { log "place neogeo.zip in $ROOT or pass --bios-zip"; exit 1; }
fi
log "ROMs staged"

CFG=(-S "$ROOT" -B "$BUILD" "-DIRONCLAD_ROM_DIR=$ROMS")
if ! need sdl2-config && [ -z "$SDL2_DIR" ] && [ "$NO_WINDOW" = 0 ]; then
  log "SDL2 not found; building headless-only (no window)"
fi
cmake "${CFG[@]}" || { log "cmake configure failed"; exit 1; }
cmake --build "$BUILD" --config Release --parallel || { log "build failed"; exit 1; }
log "built"

EXE="$BUILD/ironclad"
[ -f "$EXE" ] || EXE="$BUILD/Release/ironclad"
[ -x "$EXE" ] || { log "build produced no executable"; exit 1; }
cat > "$ROOT/ironclad.sh" <<EOF
#!/usr/bin/env bash
exec "$EXE" --rom-path "$ROMS"
EOF
chmod +x "$ROOT/ironclad.sh"
log "launcher written: run ./ironclad.sh"
log "Keys: arrows move, Z/X/C/V = A/B/C/D, 5 coin, 1 start, Esc quit."
