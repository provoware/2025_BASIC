#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
MOD=creatoros/modules/database.py
TEST=creatoros/tests/test_database.py
META=$BASE/meta/changes
CONFLICT=$BASE/conflicts

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 11 (SQLite)"
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
import sqlite3
import os

DB_PATH = "creatoros/db/steelcore.sqlite3"

def init_db(path=DB_PATH):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    conn = sqlite3.connect(path)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute("""
        CREATE TABLE IF NOT EXISTS eintrag (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titel TEXT NOT NULL,
            kategorie TEXT NOT NULL
        );
    """)
    conn.commit()
    conn.close()

def insert_eintrag(titel, kategorie, path=DB_PATH):
    conn = sqlite3.connect(path)
    conn.execute("INSERT INTO eintrag (titel, kategorie) VALUES (?, ?)", (titel, kategorie))
    conn.commit()
    conn.close()

def get_all_eintraege(path=DB_PATH):
    conn = sqlite3.connect(path)
    cur = conn.execute("SELECT titel, kategorie FROM eintrag")
    results = cur.fetchall()
    conn.close()
    return results
EOF

cat <<'EOF' > "$BASE/$TEST"
# -*- coding: utf-8 -*-
import tempfile
import os
from creatoros.modules import database

def test_sqlite_db_lifecycle():
    with tempfile.TemporaryDirectory() as tmp:
        db_path = os.path.join(tmp, "test.sqlite3")
        database.init_db(db_path)
        database.insert_eintrag("Test", "KategorieA", db_path)
        result = database.get_all_eintraege(db_path)
        assert len(result) == 1
        assert result[0][0] == "Test"
EOF

chmod +x "$BASE/$MOD"

TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 11\nZeit: $TIMESTAMP\nBeschreibung: SQLite-Modul mit Tabelle & Test\nDateien:\n  - $BASE/$MOD\n  - $BASE/$TEST" > "$META/change_11.txt"
echo "Update 11 applied $TIMESTAMP" >> "$BASE/info-stand.txt"
md5sum "$BASE/$MOD" "$BASE/$TEST" >> "$BASE/CHECKSUMS.txt"

echo "✅ Update 11 erfolgreich abgeschlossen."
