#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
MOD=creatoros/interface/theme_manager.py
TEST=creatoros/tests/test_theme_manager.py
META=$BASE/meta/changes
CONFLICT=$BASE/conflicts

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 12 (Theme-Manager)"
  echo "$BASE/$MOD"
  echo "$BASE/$TEST"
  exit 0
fi

mkdir -p "$BASE/$(dirname $MOD)" "$BASE/$(dirname $TEST)" "$META" "$CONFLICT"

for f in "$BASE/$MOD" "$BASE/$TEST"; do
  if [ -f "$f" ]; then
    mv "$f" "$CONFLICT/$(basename "$f").bak.$(date +%s)"
    echo "[WARNUNG] $f verschoben"
  fi
done

cat <<'EOF' > "$BASE/$MOD"
# -*- coding: utf-8 -*-
import json
import os

THEME_FILE = "creatoros/system/theme.json"
VALID_THEMES = ["hell", "dunkel", "barrierefrei"]

def get_current_theme(path=THEME_FILE):
    if not os.path.exists(path):
        return "hell"
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data.get("theme", "hell")

def set_theme(name, path=THEME_FILE):
    if name not in VALID_THEMES:
        raise ValueError(f"Ungültiges Theme: {name}")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump({"theme": name}, f)
EOF

cat <<'EOF' > "$BASE/$TEST"
# -*- coding: utf-8 -*-
import tempfile
import os
import json
from creatoros.interface import theme_manager

def test_set_and_get_theme():
    with tempfile.TemporaryDirectory() as tmp:
        theme_path = os.path.join(tmp, "theme.json")
        theme_manager.set_theme("dunkel", path=theme_path)
        assert theme_manager.get_current_theme(path=theme_path) == "dunkel"

def test_invalid_theme_raises():
    with tempfile.TemporaryDirectory() as tmp:
        theme_path = os.path.join(tmp, "theme.json")
        try:
            theme_manager.set_theme("unsichtbar", path=theme_path)
            assert False, "Fehler erwartet"
        except ValueError:
            pass
EOF

chmod +x "$BASE/$MOD"

TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 12\nZeit: $TIMESTAMP\nBeschreibung: Theme-Manager mit Set/Get\nDateien:\n  - $BASE/$MOD\n  - $BASE/$TEST" > "$META/change_12.txt"
echo "Update 12 applied $TIMESTAMP" >> "$BASE/info-stand.txt"
md5sum "$BASE/$MOD" "$BASE/$TEST" >> "$BASE/CHECKSUMS.txt"

echo "✅ Update 12 erfolgreich abgeschlossen."
