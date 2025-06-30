#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
MOD=creatoros/system/logger.py
TEST=creatoros/tests/test_logger.py
META=$BASE/meta/changes
CONFLICT=$BASE/conflicts

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 14 (Zentraler Logger)"
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
import os
from datetime import datetime

LOGFILE = "creatoros/logs/steelcore.log"

def log(message, level="INFO", logfile=LOGFILE):
    os.makedirs(os.path.dirname(logfile), exist_ok=True)
    timestamp = datetime.now().isoformat()
    with open(logfile, "a", encoding="utf-8") as f:
        f.write(f"[{timestamp}] [{level}] {message}\n")

def debug(msg): log(msg, "DEBUG")
def info(msg): log(msg, "INFO")
def warn(msg): log(msg, "WARN")
def error(msg): log(msg, "ERROR")
EOF

cat <<'EOF' > "$BASE/$TEST"
# -*- coding: utf-8 -*-
import tempfile
import os
from creatoros.system import logger

def test_logging_creates_file_and_writes():
    with tempfile.TemporaryDirectory() as tmp:
        log_path = os.path.join(tmp, "log.txt")
        logger.log("Test-Eintrag", level="DEBUG", logfile=log_path)
        assert os.path.isfile(log_path)
        with open(log_path) as f:
            content = f.read()
            assert "Test-Eintrag" in content
EOF

chmod +x "$BASE/$MOD"

TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 14\nZeit: $TIMESTAMP\nBeschreibung: Logging-Modul mit Levels\nDateien:\n  - $BASE/$MOD\n  - $BASE/$TEST" > "$META/change_14.txt"
echo "Update 14 applied $TIMESTAMP" >> "$BASE/info-stand.txt"
md5sum "$BASE/$MOD" "$BASE/$TEST" >> "$BASE/CHECKSUMS.txt"

echo "✅ Update 14 erfolgreich abgeschlossen."
