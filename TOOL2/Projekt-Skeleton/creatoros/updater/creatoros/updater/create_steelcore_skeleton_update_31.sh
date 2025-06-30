#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
META=$BASE/meta/changes
INFO=creatoros/updater/info-stand.txt
SUMS=creatoros/updater/CHECKSUMS.txt

SRC="$BASE/start_gui_dashboard.sh"
DST="start_gui_dashboard.sh"

echo "=== Update 31: Start-Skript ins Projekt-Root verschieben ==="

# 1) Prüfen, ob Source existiert
if [ ! -f "$SRC" ]; then
  echo "❌ Quelle $SRC nicht gefunden. Abbruch."
  exit 1
fi
echo "▶️ Quelle gefunden: $SRC"

# 2) Backup am Ziel (falls bereits vorhanden)
if [ -f "$DST" ]; then
  mkdir -p "$BASE/conflicts"
  mv "$DST" "$BASE/conflicts/${DST}.$(date +%s).bak"
  echo "⚠️ Backup: vorhandenes $DST → conflicts/"
fi

# 3) Verschieben
mv "$SRC" "$DST"
chmod +x "$DST"
echo "   ✔ $DST verschoben und ausführbar gemacht."

# 4) Meta & Checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_31.txt"
ID: 31
Zeit: $STAMP
Beschreibung: Verschiebe start_gui_dashboard.sh ins Projekt-Root
Dateien:
  - $DST
EOF

echo "Update 31 applied $STAMP" >> "$INFO"
md5sum "$DST" >> "$SUMS"

echo "✅ Update 31 erfolgreich abgeschlossen."
