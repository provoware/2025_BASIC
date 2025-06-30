#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
MOD=creatoros/system/cleanup_manager.py
TEST=creatoros/tests/test_cleanup_manager.py
START=start_cleanup.sh
META=$BASE/meta/changes
CONFLICT=$BASE/conflicts

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 16 (Cleanup-Modul)"
  echo "$BASE/$MOD"
  echo "$BASE/$TEST"
  echo "$START"
  exit 0
fi

mkdir -p "$BASE/$(dirname $MOD)" "$BASE/$(dirname $TEST)" "$META" "$CONFLICT"

for f in "$BASE/$MOD" "$BASE/$TEST" "$START"; do
  if [ -f "$f" ]; then
    mv "$f" "$CONFLICT/$(basename "$f").bak.$(date +%s)"
    echo "[WARNUNG] $f verschoben"
  fi
done

cat <<'EOF' > "$BASE/$MOD"
# -*- coding: utf-8 -*-
import os
import hashlib

SKEL_ROOT = "creatoros"
KNOWN_FOLDERS = {"boot", "system", "interface", "modules", "db", "logs", "plugins", "tests", "updater"}
PROTECTED_FILES = {"README.md", ".gitignore"}

def find_orphans():
    orphans = []
    for root, dirs, files in os.walk(SKEL_ROOT):
        for file in files:
            full = os.path.relpath(os.path.join(root, file), start=SKEL_ROOT)
            if full.startswith("updater/meta") or full.startswith("updater/conflicts"):
                continue
            if not any(part in KNOWN_FOLDERS for part in full.split(os.sep)):
                orphans.append(full)
    return orphans

def md5_of_file(filepath):
    with open(filepath, "rb") as f:
        return hashlib.md5(f.read()).hexdigest()

def dry_report():
    orphans = find_orphans()
    print("🔎 Orphan-Dateien (nicht zugeordnet):")
    for o in orphans:
        print(f"  - {o}")

if __name__ == "__main__":
    dry_report()
EOF

cat <<'EOF' > "$BASE/$TEST"
# -*- coding: utf-8 -*-
import os
from creatoros.system import cleanup_manager

def test_dry_report_runs():
    cleanup_manager.dry_report()
EOF

cat <<'EOF' > "$START"
#!/usr/bin/env bash
set -euo pipefail
python3 creatoros/system/cleanup_manager.py
EOF

chmod +x "$BASE/$MOD" "$START"

TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 16\nZeit: $TIMESTAMP\nBeschreibung: Cleanup-Modul zur Analyse\nDateien:\n  - $BASE/$MOD\n  - $BASE/$TEST\n  - $START" > "$META/change_16.txt"
echo "Update 16 applied $TIMESTAMP" >> "$BASE/info-stand.txt"
md5sum "$BASE/$MOD" "$BASE/$TEST" "$START" >> "$BASE/CHECKSUMS.txt"

echo "✅ Update 16 erfolgreich abgeschlossen."
