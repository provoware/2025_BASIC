#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
TOOL_PATH=$BASE/creatoros/tools/validate_placeholders.py
TEST_PATH=$BASE/creatoros/tests/test_validate_placeholders.py
META_PATH=$BASE/meta/changes
CONFLICT_PATH=$BASE/conflicts

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 09 (Platzhalterprüfung)"
  echo "Würde schreiben:"
  echo "$TOOL_PATH"
  echo "$TEST_PATH"
  exit 0
fi

mkdir -p $(dirname "$TOOL_PATH") $(dirname "$TEST_PATH") "$META_PATH" "$CONFLICT_PATH"

for f in "$TOOL_PATH" "$TEST_PATH"; do
  if [ -f "$f" ]; then
    mv "$f" "$CONFLICT_PATH/$(basename "$f").bak.$(date +%s)"
    echo "[WARNUNG] Datei verschoben nach conflicts/"
  fi
done

cat <<EOF > "$TOOL_PATH"
# -*- coding: utf-8 -*-
import os
import json

def validate_placeholders(base_dir="creatoros"):
    results = []
    for root, _, files in os.walk(base_dir):
        for file in files:
            if "__todo." in file:
                path = os.path.join(root, file)
                ext = file.split(".")[-1]
                try:
                    with open(path, "r", encoding="utf-8") as f:
                        content = f.read()
                    if ext == "py":
                        if "# TODO" in content and "# -*- coding: utf-8 -*-" in content:
                            results.append((path, "OK", "Python-Stub gültig"))
                        else:
                            results.append((path, "FEHLER", "Python-Stubs unvollständig"))
                    elif ext == "json":
                        json.loads(content or "{}")
                        results.append((path, "OK", "JSON-Stub gültig"))
                    elif ext in ["yml", "yaml"]:
                        results.append((path, "OK", "YAML erkannt (nicht geprüft)"))
                    elif ext == "db":
                        results.append((path, "OK", "Leere DB-Datei akzeptiert"))
                    else:
                        results.append((path, "WARNUNG", f"Unbekannte Endung: {ext}"))
                except Exception as e:
                    results.append((path, "FEHLER", f"{type(e).__name__}: {e}"))
    return results
EOF

cat <<EOF > "$TEST_PATH"
# -*- coding: utf-8 -*-
import tempfile
import os
from creatoros.tools import validate_placeholders

def test_validate_stub_py_valid():
    with tempfile.TemporaryDirectory() as tmp:
        stub = os.path.join(tmp, "valid__todo.py")
        with open(stub, "w", encoding="utf-8") as f:
            f.write("# -*- coding: utf-8 -*-\n# TODO")
        result = validate_placeholders.validate_placeholders(tmp)
        assert any("OK" in r for r in result)

def test_validate_stub_py_invalid():
    with tempfile.TemporaryDirectory() as tmp:
        stub = os.path.join(tmp, "broken__todo.py")
        with open(stub, "w", encoding="utf-8") as f:
            f.write("kein header")
        result = validate_placeholders.validate_placeholders(tmp)
        assert any("FEHLER" in r for r in result)
EOF

chmod +x "$TOOL_PATH"

TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 09\nZeit: $TIMESTAMP\nBeschreibung: Platzhalter-Checker mit Tests implementiert\nDateien:\n  - $TOOL_PATH\n  - $TEST_PATH" > "$META_PATH/change_09.txt"
echo "Update 09 applied $TIMESTAMP" >> "$BASE/info-stand.txt"
md5sum "$TOOL_PATH" "$TEST_PATH" >> "$BASE/CHECKSUMS.txt"

echo "Update 09 erfolgreich angewendet."
