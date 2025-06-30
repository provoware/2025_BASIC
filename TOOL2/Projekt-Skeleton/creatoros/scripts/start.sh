#!/usr/bin/env bash
###############################################################################
#  Steel-Core  •  start.sh  (v2.2 – robust, selbstheilend, Bash-kompatibel)
#  ▸ Erststart:  legt vollständiges, KI-freies Skeleton unter  creatoros/  an
#  ▸ Jeder Start: prüft Struktur, ergänzt fehlende Elemente, öffnet GUI-Updater
#  ▸ --force     löscht vorhandenes Skeleton und baut es frisch auf
###############################################################################
set -Eeuo pipefail
ROOT="creatoros"
INFO="$ROOT/info-stand.txt"
UPDATER="$ROOT/updater/update_manager__todo.py"
PYBIN=python3

# ---------------- Farbhelper (abschaltbar via NO_COLOR=1) -------------------
c(){ [[ -z ${NO_COLOR:-} ]] && printf '\e[%sm%s\e[0m' "$1" "$2" || printf '%s' "$2"; }

# ---------------- Platzhalter-Funktion --------------------------------------
stub(){                               # stub  <relpath>  <ext>
  local f="$ROOT/$1__todo.$2"; mkdir -p "$(dirname "$f")"
  case $2 in
    py|sh)   echo "# TODO" >"$f" ;;
    json)    echo '{ "TODO": true }' >"$f" ;;
    md|txt|yml|yaml|toml) echo "# TODO" >"$f" ;;
    db)      : >"$f" ;;
    *)       echo "# TODO" >"$f" ;;
  esac
  [[ $2 == sh ]] && chmod +x "$f"
}

# ---------------- Ordnerliste (ohne KI) -------------------------------------
DIRS=(
  boot system interface modules plugins/sample config core_fallback
  db data/audio_refs data/.trash logs meta docs/user docs/dev docs/legal
  snapshots tests tools vendor runtime updater
  scripts/packaging/debian scripts/packaging/appimage .github/workflows dist
)

# ---------------- Pflicht-Stubdateien ---------------------------------------
STUB_KEYS=(
  "start_tool|py"                   "start_debug|py"          "run|py"
  "boot/boot_checker|py"            "system/dispatcher|py"
  "interface/controller|py"         "updater/update_manager|py"
  "config/settings|json"            "core_fallback/default_settings|json"
  "meta/tool_manifest|json"         "db/local_store|db"
)

# ---------------- Skeleton-Aufbau / Reparatur -------------------------------
[[ ${1:-} == --force ]] && { rm -rf "$ROOT"; echo "$(c 33 ⚠)  altes Skeleton gelöscht (--force)"; }

[[ -d $ROOT ]] || mkdir -p "$ROOT"

for d in "${DIRS[@]}"; do
  [[ -d "$ROOT/$d" ]] || { mkdir -p "$ROOT/$d"; echo "  $(c 33 ➕) Ordner  $d"; }
done

for item in "${STUB_KEYS[@]}"; do
  name=${item%%|*}; ext=${item##*|}
  [[ -f "$ROOT/${name}__todo.$ext" ]] || { stub "$name" "$ext"; echo "  $(c 33 ➕) Datei   ${name}__todo.$ext"; }
done

# spezielle Hinweis-Dateien (Vendor / Runtime)
echo "# Wheels hier hinein"            > "$ROOT/vendor/README__todo.txt"
echo "# Embeddable CPython hier hinein" > "$ROOT/runtime/README__todo.txt"

# .keep-Dateien für leere Ordner
find "$ROOT" -type d -empty -exec touch {}/.keep__todo \;

# info-stand.txt initialisieren
[[ -f $INFO ]] || echo "Skeleton initial angelegt  ($(date -R))" >"$INFO"

echo "$(c 32 ✔)  Skeleton konsistent."

# ---------------- GUI-Updater starten ---------------------------------------
echo "$(c 34 ℹ)  Starte Update-Manager …"
command -v "$PYBIN" >/dev/null 2>&1 || { echo "Python ($PYBIN) fehlt"; exit 1; }
"$PYBIN" "$UPDATER"
