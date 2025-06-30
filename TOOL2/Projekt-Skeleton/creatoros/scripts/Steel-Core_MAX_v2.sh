#!/usr/bin/env bash
###############################################################################
#  Steel-Core  MAX v2.1  –  start.sh  (self-healing)
###############################################################################
set -Eeuo pipefail
ROOT="creatoros"
INFO="$ROOT/info-stand.txt"
UPDATER="$ROOT/updater/update_manager__todo.py"
PYBIN=python3

# --- Farbausgabe -------------------------------------------------------------
c(){ [[ -z ${NO_COLOR:-} ]] && printf '\e[%sm%s\e[0m' "$1" "$2" || printf '%s' "$2"; }

# --- Platzhalter -------------------------------------------------------------
stub(){ f="$ROOT/$1__todo.$2"; mkdir -p "$(dirname "$f")";
        case $2 in py|sh) echo "# TODO" >"$f";; json) echo '{ "TODO": true }' >"$f";;
                         md|txt|yml|yaml|toml) echo "# TODO" >"$f";; db) : >"$f";; esac
        [[ $2 == sh ]] && chmod +x "$f"; }

# --- vollständige Ordnerliste (ohne KI) --------------------------------------
read -r -d '' DIRS <<'D'
boot system interface modules plugins/sample config core_fallback
db data/audio_refs data/.trash logs meta docs/user docs/dev docs/legal
snapshots tests tools vendor runtime updater scripts/packaging/debian
scripts/packaging/appimage .github/workflows dist
D
IFS=$'\n' read -r -d '' -a DIR_ARRAY <<<"$DIRS"; unset IFS

# --- vollständige Pflicht-Dateien -------------------------------------------
read -r -d '' STUBS <<'S'
start_tool|py
start_debug|py
run|py
boot/boot_checker|py
system/dispatcher|py
interface/controller|py
updater/update_manager|py
config/settings|json
core_fallback/default_settings|json
meta/tool_manifest|json
db/local_store|db
S
IFS=$'\n' read -r -d '' -a STUB_ARRAY <<<"$STUBS"; unset IFS

# ---------- Skeleton-Reparatur/Erstellung -----------------------------------
echo "$(c 34 ℹ)  Prüfe/erstelle Skeleton …"
[[ -d $ROOT ]] || mkdir -p "$ROOT"

# ▸ Ordner
for d in "${DIR_ARRAY[@]}"; do
  [[ -d "$ROOT/$d" ]] || { mkdir -p "$ROOT/$d"; echo "  $(c 33 '➕') Ordner $d ergänzt"; }
done

# ▸ Platzhalter-Dateien
for s in "${STUB_ARRAY[@]}"; do
  name=${s%%|*}; ext=${s##*|}
  [[ -f "$ROOT/${name}__todo.$ext" ]] || { stub "$name" "$ext"; echo "  $(c 33 '➕') Datei $name__todo.$ext"; }
done

# ▸ leere Ordner sichern
find "$ROOT" -type d -empty -exec touch {}/.keep__todo \; 2>/dev/null

# ▸ info-stand.txt initialisieren
[[ -f $INFO ]] || echo "Skeleton initial angelegt $(date -R)" >"$INFO"

echo "$(c 32 ✔)  Skeleton konsistent."

# ---------- Updater-GUI starten ---------------------------------------------
echo "$(c 34 ℹ)  Starte Update-Manager …"
command -v "$PYBIN" >/dev/null 2>&1 || { echo "Python ($PYBIN) fehlt."; exit 1; }
"$PYBIN" "$UPDATER"
