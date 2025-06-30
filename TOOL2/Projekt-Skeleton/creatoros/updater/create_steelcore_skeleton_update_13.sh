#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
MOD=creatoros/modules/plugin_manager.py
TEST=creatoros/tests/test_plugin_manager.py
META=$BASE/meta/changes
CONFLICT=$BASE/conflicts

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 13 (Plugin-Manager)"
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
import importlib.util
import os

PLUGIN_DIR = "creatoros/plugins"

def list_plugins():
    return [f for f in os.listdir(PLUGIN_DIR) if f.endswith(".py")]

def load_and_run_plugins():
    results = []
    for fname in list_plugins():
        path = os.path.join(PLUGIN_DIR, fname)
        spec = importlib.util.spec_from_file_location(fname.replace(".py", ""), path)
        if spec and spec.loader:
            try:
                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)
                if hasattr(module, "main") and callable(module.main):
                    result = module.main()
                    results.append((fname, "OK", result))
                else:
                    results.append((fname, "FEHLER", "Keine main()-Funktion"))
            except Exception as e:
                results.append((fname, "FEHLER", str(e)))
    return results
EOF

cat <<'EOF' > "$BASE/$TEST"
# -*- coding: utf-8 -*-
import tempfile
import os
from creatoros.modules import plugin_manager

def test_valid_plugin_runs():
    with tempfile.TemporaryDirectory() as tmp:
        fname = os.path.join(tmp, "test_plugin.py")
        with open(fname, "w") as f:
            f.write("def main(): return 'Hallo'")
        os.makedirs("creatoros/plugins", exist_ok=True)
        os.replace(fname, "creatoros/plugins/test_plugin.py")
        results = plugin_manager.load_and_run_plugins()
        assert any("OK" in r for r in results)

def test_missing_main_fails():
    with tempfile.TemporaryDirectory() as tmp:
        fname = os.path.join(tmp, "broken_plugin.py")
        with open(fname, "w") as f:
            f.write("def not_main(): pass")
        os.makedirs("creatoros/plugins", exist_ok=True)
        os.replace(fname, "creatoros/plugins/broken_plugin.py")
        results = plugin_manager.load_and_run_plugins()
        assert any("FEHLER" in r and "main" in r[2] for r in results)
EOF

chmod +x "$BASE/$MOD"

TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 13\nZeit: $TIMESTAMP\nBeschreibung: Plugin-Manager mit Laufzeitprüfung\nDateien:\n  - $BASE/$MOD\n  - $BASE/$TEST" > "$META/change_13.txt"
echo "Update 13 applied $TIMESTAMP" >> "$BASE/info-stand.txt"
md5sum "$BASE/$MOD" "$BASE/$TEST" >> "$BASE/CHECKSUMS.txt"

echo "✅ Update 13 erfolgreich abgeschlossen."
